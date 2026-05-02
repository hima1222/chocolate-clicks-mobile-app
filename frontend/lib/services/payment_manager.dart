import 'package:flutter/material.dart';

/// Payment Manager - Handles payment flow and state management
class PaymentManager {
  /// Tracks the current cart total
  static double cartTotal = 0.0;

  /// Updates cart total
  static void updateCartTotal(double amount) {
    cartTotal = amount;
  }

  /// Initiates payment flow
  static void initiatePayment(BuildContext context, double amount) {
    updateCartTotal(amount);
    Navigator.pushNamed(context, '/payment_method');
  }
}
