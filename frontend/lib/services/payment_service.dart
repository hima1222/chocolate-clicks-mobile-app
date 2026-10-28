import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../models/order_pricing.dart';
import 'storage_service.dart';
import 'payhere_web_stub.dart' if (dart.library.js_interop) 'payhere_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/secure_checkout_screen.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'package:chocolate_clicks/models/payment_info.dart';

/// Service for managing payment information
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final List<PaymentInfo> _methods = [];
  Map<String, String> get _headers {
    final token = AuthService().authToken;
    if (token == null) throw Exception('Please log in to pay.');
    return {'Authorization': 'Bearer $token'};
  }

  static Map<String, dynamic> orderData(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map || (data['_id'] ?? data['id']) == null) {
      throw const FormatException(
        'The server returned an incomplete order. Please restart the updated backend and try again.',
      );
    }
    return Map<String, dynamic>.from(data);
  }

  static Map<String, dynamic> checkoutPayload(Map<String, dynamic> response) {
    final checkout = response['checkout'];
    if (checkout is! Map ||
        checkout['order_id'] == null ||
        checkout['amount'] == null) {
      throw const FormatException(
        'PayHere checkout was not returned by the server. Restart the updated backend, then continue payment from Order Details.',
      );
    }
    return Map<String, dynamic>.from(checkout);
  }

  Future<OrderPricing> quoteProducts(
    List<CartItem> items, {
    String city = '',
  }) async {
    final response = await ApiClient().post(
      '/orders/quote',
      body: {
        'items': items
            .map((item) => {'productId': item.id, 'quantity': item.quantity})
            .toList(),
        'city': city,
      },
    );
    final data = response['data'];
    if (data is! Map || data['pricing'] is! Map) {
      throw const FormatException(
        'Unable to load delivery charges. Restart the updated backend and reload prices.',
      );
    }
    return OrderPricing.fromJson(Map<String, dynamic>.from(data['pricing']));
  }

  Future<EventPaymentOrder> fetchOrder(String id) async {
    final response = await ApiClient().get('/orders/$id', headers: _headers);
    return EventPaymentOrder.fromJson(orderData(response));
  }

  Future<EventPaymentOrder> pollOrder(String id) async {
    var order = await fetchOrder(id);
    for (var attempt = 0; attempt < 6 && order.status == 'pending'; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      order = await fetchOrder(id);
    }
    return order;
  }

  Future<EventCheckoutResult> checkoutEvent({
    required String eventId,
    required int quantity,
    required Map<String, String> billing,
    required void Function(String) onOrderCreated,
    required VoidCallback onProcessing,
    bool retryExisting = false,
    required NavigatorState navigator,
  }) async {
    _checkPlatform();
    final response = await ApiClient().post(
      '/orders',
      headers: _headers,
      body: {
        'eventId': eventId,
        'quantity': quantity,
        'billing': billing,
        'platform': kIsWeb ? 'web' : 'native',
      },
    );
    onOrderCreated(orderData(response)['_id'].toString());
    return _finishCheckout(
      response,
      onProcessing: onProcessing,
      retryExisting: retryExisting,
      navigator: navigator,
    );
  }

  void _checkPlatform() {
    if (!kIsWeb &&
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      throw Exception(
        'Open the web app or Android/iOS app to use PayHere checkout.',
      );
    }
  }

  Future<EventCheckoutResult> _finishCheckout(
    Map<String, dynamic> response, {
    required VoidCallback onProcessing,
    bool retryExisting = false,
    required NavigatorState navigator,
  }) async {
    final order = EventPaymentOrder.fromJson(orderData(response));
    if (order.status == 'paid') return EventCheckoutResult(order);
    final checkout = checkoutPayload(response);
    if (!navigator.mounted) {
      throw Exception('Checkout was closed. You can continue from My Orders.');
    }
    final message = await navigator.push<String>(
      MaterialPageRoute(
        builder: (_) =>
            SecureCheckoutScreen(payment: checkout, launch: _launchPayment),
      ),
    );
    if (message != 'submitted') {
      throw Exception(
        message ??
            'Payment was not completed. Continue payment when you are ready.',
      );
    }
    onProcessing();
    return EventCheckoutResult(await pollOrder(order.id));
  }

  Future<String?> _launchPayment(Map<String, dynamic> checkout) async {
    if (kIsWeb) return startWebPayment(checkout);
    final completion = Completer<String?>();
    void finish(String? message) {
      if (!completion.isCompleted) completion.complete(message);
    }

    try {
      PayHere.startPayment(
        checkout,
        (_) => finish(null),
        (error) => finish('Checkout error: $error'),
        () => finish('Checkout dismissed.'),
      );
    } catch (error) {
      finish('Unable to open checkout: $error');
    }
    final message = await completion.future.timeout(
      const Duration(minutes: 10),
      onTimeout: () =>
          'Checkout did not respond. Check your order status before retrying.',
    );
    return message;
  }

  Future<EventCheckoutResult> checkoutProducts({
    required NavigatorState navigator,
    required List<CartItem> items,
    bool fromCart = false,
    required double expectedTotal,
    required Map<String, String> billing,
    required void Function(Order) onOrderCreated,
    required VoidCallback onProcessing,
  }) async {
    _checkPlatform();
    final user = AuthService().currentUser;
    if (user == null) throw Exception('Please log in to pay.');
    final lines =
        items
            .map((item) => {'productId': item.id, 'quantity': item.quantity})
            .toList()
          ..sort(
            (a, b) =>
                a['productId'].toString().compareTo(b['productId'].toString()),
          );
    final total = expectedTotal;
    final fingerprint = jsonEncode({
      'items': lines,
      'billing': billing,
      'total': total,
      'fromCart': fromCart,
    });
    final storage = StorageService();
    final storageKey = 'product_checkout_${user.id}';
    final saved = await storage.getString(storageKey);
    Map<String, dynamic>? draft;
    if (saved != null) {
      try {
        draft = jsonDecode(saved) as Map<String, dynamic>;
      } catch (_) {}
    }
    final key = draft?['fingerprint'] == fingerprint
        ? draft!['key'] as String
        : base64UrlEncode(
            List<int>.generate(24, (_) => Random.secure().nextInt(256)),
          );
    await storage.save(
      storageKey,
      jsonEncode({'key': key, 'fingerprint': fingerprint}),
    );
    final response = await ApiClient().post(
      '/orders',
      headers: _headers,
      body: {
        'items': lines,
        'billing': billing,
        'expectedTotal': total,
        'checkoutKey': key,
        'fromCart': fromCart,
        'platform': kIsWeb ? 'web' : 'native',
      },
    );
    onOrderCreated(Order.fromJson(orderData(response)));
    final result = await _finishCheckout(
      response,
      onProcessing: onProcessing,
      navigator: navigator,
    );
    if (result.order.status == 'paid') await storage.delete(storageKey);
    return result;
  }

  Future<EventCheckoutResult> resumeCheckout(
    String orderId, {
    required VoidCallback onProcessing,
    required NavigatorState navigator,
  }) async {
    _checkPlatform();
    final response = await ApiClient().post(
      '/orders/$orderId/checkout',
      headers: _headers,
      body: {'platform': kIsWeb ? 'web' : 'native'},
    );
    return _finishCheckout(
      response,
      onProcessing: onProcessing,
      retryExisting: true,
      navigator: navigator,
    );
  }

  Future<void> clearPaidCheckoutDraft(Order order) async {
    if (order.paymentStatus != 'paid' || order.checkoutKey == null) return;
    final storage = StorageService();
    final key = 'product_checkout_${order.userId}';
    final saved = await storage.getString(key);
    if (saved == null) return;
    try {
      if ((jsonDecode(saved) as Map)['key'] == order.checkoutKey) {
        await storage.delete(key);
      }
    } catch (_) {}
  }

  /// Fetch saved payment methods
  Future<List<PaymentInfo>> fetchPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_methods);
  }

  /// Add or update payment method
  Future<void> addOrUpdateMethod(PaymentInfo info) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _methods.indexWhere((m) => m.id == info.id);
    if (idx >= 0) {
      _methods[idx] = info;
    } else {
      _methods.add(info);
    }
  }

  /// Remove payment method
  Future<void> removeMethod(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _methods.removeWhere((m) => m.id == id);
  }

  /// Clear methods (e.g., logout)
  void clear() => _methods.clear();
}

class EventPaymentOrder {
  const EventPaymentOrder({required this.id, required this.status});
  final String id;
  final String status;
  factory EventPaymentOrder.fromJson(Map<String, dynamic> json) =>
      EventPaymentOrder(
        id: json['_id'].toString(),
        status: json['payment_status'] as String,
      );
}

class EventCheckoutResult {
  const EventCheckoutResult(this.order, {this.message});
  final EventPaymentOrder order;
  final String? message;
}
