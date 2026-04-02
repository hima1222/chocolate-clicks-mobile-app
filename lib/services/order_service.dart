import 'package:chocolate_clicks/models/order_model.dart';
import 'package:chocolate_clicks/models/cart_item.dart';

/// Service for managing orders and transactions
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List<Order> _orders = [];

  /// Place a new order
  Future<Order> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
    String? deliveryAddress,
    String? notes,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      // TODO: Replace with API call

      final order = Order(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: deliveryAddress,
        notes: notes,
      );

      _orders.add(order);
      return order;
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  /// Fetch all orders for a user
  Future<List<Order>> fetchUserOrders(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      // TODO: Replace with API call
      return _orders.where((o) => o.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Fetch single order by ID
  Future<Order?> fetchOrderById(String orderId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      // TODO: Replace with API call
      return _orders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: Replace with API call

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index == -1) return false;

      final order = _orders[index];
      if (order.status == OrderStatus.completed ||
          order.status == OrderStatus.cancelled) {
        throw Exception('Cannot cancel this order');
      }

      _orders[index] = Order(
        id: order.id,
        userId: order.userId,
        items: order.items,
        totalAmount: order.totalAmount,
        status: OrderStatus.cancelled,
        createdAt: order.createdAt,
        completedAt: DateTime.now(),
        deliveryAddress: order.deliveryAddress,
        notes: order.notes,
      );

      return true;
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  /// Update order status (admin only)
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: Replace with API call

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index == -1) throw Exception('Order not found');

      final order = _orders[index];
      final updated = Order(
        id: order.id,
        userId: order.userId,
        items: order.items,
        totalAmount: order.totalAmount,
        status: status,
        createdAt: order.createdAt,
        completedAt: status == OrderStatus.completed
            ? DateTime.now()
            : order.completedAt,
        deliveryAddress: order.deliveryAddress,
        notes: order.notes,
      );

      _orders[index] = updated;
      return updated;
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  /// Clear all orders (on logout)
  void clear() {
    _orders.clear();
  }
}
