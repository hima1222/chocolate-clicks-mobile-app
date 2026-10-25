import 'package:chocolate_clicks/models/cart_item.dart';

/// Service handling the user's shopping cart operations
class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  /// Fetch current cart items
  Future<List<CartItem>> fetchCartItems() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_items);
  }

  /// Add or update item in cart
  Future<void> addOrUpdateItem(CartItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      // Item exists - increment quantity
      final existingItem = _items[index];
      _items[index] = CartItem(
        id: existingItem.id,
        name: existingItem.name,
        price: existingItem.price,
        quantity: existingItem.quantity + item.quantity,
        imageUrl: existingItem.imageUrl,
      );
    } else {
      // New item - add to cart
      _items.add(item);
    }
  }

  /// Remove an item from the cart
  Future<void> removeItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((i) => i.id == itemId);
  }

  final Set<String> _consumedOrders = {};
  final Set<String> _pendingCartOrders = {};
  void trackCheckout(String orderId) {
    if (!_consumedOrders.contains(orderId)) _pendingCartOrders.add(orderId);
  }

  void removePaidItems(String orderId, List<CartItem> purchased) {
    if (!_pendingCartOrders.remove(orderId) || !_consumedOrders.add(orderId))
      return;
    for (final item in purchased) {
      var remaining = item.quantity;
      for (
        var index = _items.length - 1;
        index >= 0 && remaining > 0;
        index--
      ) {
        final current = _items[index];
        if (current.id != item.id &&
            current.name.trim().toLowerCase() !=
                item.name.trim().toLowerCase()) {
          continue;
        }
        if (current.quantity <= remaining) {
          remaining -= current.quantity;
          _items.removeAt(index);
        } else {
          _items[index] = CartItem(
            id: current.id,
            name: current.name,
            price: current.price,
            quantity: current.quantity - remaining,
            imageUrl: current.imageUrl,
          );
          remaining = 0;
        }
      }
    }
  }

  /// Clear all cart items (e.g. after checkout or logout)
  void clear() {
    _items.clear();
    _consumedOrders.clear();
    _pendingCartOrders.clear();
  }
}
