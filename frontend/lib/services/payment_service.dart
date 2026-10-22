import 'dart:async';
import 'package:flutter/foundation.dart';
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

  Future<EventPaymentOrder> fetchOrder(String id) async {
    final response = await ApiClient().get('/orders/$id', headers: _headers);
    return EventPaymentOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<EventPaymentOrder> pollOrder(String id) async {
    var order = await fetchOrder(id);
    for (var attempt = 0; attempt < 6 && order.status != 'paid'; attempt++) {
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
  }) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      throw Exception(
        'PayHere checkout is available in the Android and iOS apps.',
      );
    }
    final response = await ApiClient().post(
      '/orders',
      headers: _headers,
      body: {'eventId': eventId, 'quantity': quantity, 'billing': billing},
    );
    final order = EventPaymentOrder.fromJson(
      response['data'] as Map<String, dynamic>,
    );
    onOrderCreated(order.id);
    if (order.status == 'paid') return EventCheckoutResult(order);
    if (response['reused'] == true && !retryExisting) {
      onProcessing();
      return EventCheckoutResult(await pollOrder(order.id));
    }
    final completion = Completer<String?>();
    void finish(String? message) {
      if (!completion.isCompleted) completion.complete(message);
    }

    try {
      PayHere.startPayment(
        Map<String, dynamic>.from(response['checkout'] as Map),
        (_) => finish(null),
        (error) => finish('Checkout error: $error'),
        () => finish('Checkout dismissed.'),
      );
    } catch (error) {
      finish('Unable to open checkout: $error');
    }
    final message = await completion.future;
    onProcessing();
    // Neither SDK success nor dismissal is evidence of payment.
    return EventCheckoutResult(await pollOrder(order.id), message: message);
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
