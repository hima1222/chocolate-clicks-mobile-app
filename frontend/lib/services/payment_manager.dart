import 'package:flutter/material.dart';
import '../models/cart_item.dart';

/// Payment Manager - Handles payment flow and state management
class PaymentManager {
  /// Tracks the current cart total
  static double cartTotal = 0.0;
  static List<CartItem>? checkoutItems;
  static bool checkoutFromCart = false;

  /// Updates cart total
  static void updateCartTotal(double amount) {
    cartTotal = amount;
  }

  /// Initiates payment flow
  static Future<void> initiatePayment(
    BuildContext context,
    double amount, {
    List<CartItem>? items,
    bool fromCart = false,
  }) async {
    checkoutFromCart = fromCart;
    checkoutItems = items == null ? null : List.unmodifiable(items);
    updateCartTotal(amount);
    await Navigator.pushNamed(context, '/payment_summary');
  }
}
