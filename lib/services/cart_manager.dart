import 'package:flutter/material.dart';

class CartItem {
  final String image;
  final String title;
  final double price;

  CartItem({required this.image, required this.title, required this.price});
}

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();

  factory CartManager() => _instance;

  CartManager._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get total => _items.fold(0.0, (sum, item) => sum + item.price);

  void add(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
