import 'package:chocolate_clicks/models/payment_info.dart';

/// Service for managing payment information
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final List<PaymentInfo> _methods = [];

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
