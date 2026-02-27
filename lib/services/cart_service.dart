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
      _items[index] = item;
    } else {
      _items.add(item);
    }
  }

  /// Remove an item from the cart
  Future<void> removeItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((i) => i.id == itemId);
  }

  /// Clear all cart items (e.g. after checkout or logout)
  void clear() {
    _items.clear();
  }
}
