import 'package:chocolate_clicks/models/cart_item.dart';
import 'order_pricing.dart';

/// Order status enum
enum OrderStatus { pending, confirmed, preparing, ready, completed, cancelled }

extension OrderStatusExt on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Order model representing a purchase
class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? deliveryAddress;
  final String? notes;
  final String? eventTitle;
  final String? paymentStatus;
  final bool fromCart;
  final String? checkoutKey;
  final OrderPricing? pricing;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.deliveryAddress,
    this.notes,
    this.eventTitle,
    this.paymentStatus,
    this.fromCart = false,
    this.checkoutKey,
    this.pricing,
  });

  Map<String, dynamic> toJson() {
    return {
      'pricing': pricing?.toJson(),
      'id': id,
      'userId': userId,
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'notes': notes,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json['_id'] ?? json['id']).toString(),
      userId: (json['userId'] ?? json['user'] ?? '').toString(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      deliveryAddress: json['deliveryAddress'] as String?,
      notes: json['notes'] as String?,
      eventTitle: json['eventTitle'] as String?,
      paymentStatus: json['payment_status'] as String?,
      fromCart: json['fromCart'] == true,
      checkoutKey: json['checkoutKey'] as String?,
      pricing: json['pricing'] is Map
          ? OrderPricing.fromJson(Map<String, dynamic>.from(json['pricing']))
          : null,
    );
  }
}
