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

  Future<List<CartItem>> resolveCheckoutItems(List<CartItem> items) async {
    final response = await ApiClient().get('/products');
    final catalog = (response['data'] as List).cast<Map<String, dynamic>>();
    return items.map((item) {
      final byId = catalog
          .where((p) => p['_id'].toString() == item.id)
          .toList();
      final matches = byId.isNotEmpty
          ? byId
          : catalog
                .where(
                  (p) =>
                      p['name'].toString().trim().toLowerCase() ==
                      item.name.trim().toLowerCase(),
                )
                .toList();
      if (matches.length != 1) {
        throw Exception(
          '${item.name} is unavailable. Please contact the shop.',
        );
      }
      final product = matches.single;
      return CartItem(
        id: product['_id'].toString(),
        name: product['name'].toString(),
        price: (product['price'] as num).toDouble(),
        quantity: item.quantity,
        imageUrl: (product['imageUrl'] ?? item.imageUrl).toString(),
      );
    }).toList();
  }

  /// Fetch all orders for a user
  Future<List<Order>> fetchUserOrders(String userId) async {
    try {
      final authService = AuthService();
      final token = authService.authToken;
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await ApiClient().get(
        '/orders',
        headers: {'Authorization': 'Bearer $token'},
      );

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

      final response = await ApiClient().get(
        '/orders/$orderId',
        headers: {'Authorization': 'Bearer $token'},
      );

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

      final response = await ApiClient().put(
        '/orders/$orderId/cancel',
        body: {},
        headers: {'Authorization': 'Bearer $token'},
      );

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
      final token = AuthService().authToken;
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await ApiClient().put(
        '/orders/$orderId/status',
        body: {'status': status.name},
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update order status');
      }
      return Order.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  /// Clear all orders (on logout)
  void clear() {
    _orders.clear();
  }
}
