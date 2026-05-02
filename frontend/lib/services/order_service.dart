import 'package:chocolate_clicks/models/order_model.dart';
import 'package:chocolate_clicks/models/cart_item.dart';
import 'package:chocolate_clicks/services/api_client.dart';
import 'package:chocolate_clicks/services/auth_service.dart';

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
      final authService = AuthService();
      final token = authService.authToken;
      if (token == null) {
        throw Exception('Authentication required');
      }

      final orderItems = items.map((item) => {
        'productId': item.id,
        'quantity': item.quantity,
      }).toList();

      final response = await ApiClient().post('/orders', body: {
        'items': orderItems,
        'totalAmount': totalAmount,
        'deliveryAddress': deliveryAddress,
        'notes': notes,
      }, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response['success'] == true) {
        return Order.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  /// Fetch all orders for a user
  Future<List<Order>> fetchUserOrders(String userId) async {
    try {
      final authService = AuthService();
      final token = authService.authToken;
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await ApiClient().get('/orders', headers: {
        'Authorization': 'Bearer $token',
      });

      if (response['success'] == true) {
        final orders = (response['data'] as List)
            .map((o) => Order.fromJson(o))
            .toList();
        return orders;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Fetch single order by ID
  Future<Order?> fetchOrderById(String orderId) async {
    try {
      final authService = AuthService();
      final token = authService.authToken;
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await ApiClient().get('/orders/$orderId', headers: {
        'Authorization': 'Bearer $token',
      });

      if (response['success'] == true) {
        return Order.fromJson(response['data']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final authService = AuthService();
      final token = authService.authToken;
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await ApiClient().put('/orders/$orderId/cancel', body: {}, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response['success'] == true) {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to cancel order');
      }
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
