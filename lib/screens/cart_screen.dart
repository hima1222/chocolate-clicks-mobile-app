import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/cart_service.dart';
import 'package:chocolate_clicks/models/cart_item.dart';
import '../services/payment_manager.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cart = CartService();
  List<CartItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _cart.fetchCartItems();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _remove(String id) async {
    await _cart.removeItem(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fav_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _items.isEmpty
                        ? const Center(
                            child: Text(
                              'Your cart is empty',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                color: Colors.white.withOpacity(0.9),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: Image.network(
                                    item.imageUrl,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(item.name),
                                  subtitle: Text(
                                    'Rs. ${item.price.toStringAsFixed(0)}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _remove(item.id),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (_items.isNotEmpty) ...[
                    Text(
                      'Total: Rs. ${_items.fold<double>(0, (sum, i) => sum + i.totalPrice).toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // directly pay total
                          final total = _items.fold<double>(
                            0,
                            (sum, i) => sum + i.totalPrice,
                          );
                          PaymentManager.initiatePayment(context, total);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            245,
                            157,
                            74,
                          ),
                        ),
                        child: const Text('Buy Now'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
