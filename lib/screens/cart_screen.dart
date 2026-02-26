import 'package:flutter/material.dart';
import '../services/cart_manager.dart';
import '../services/payment_manager.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartManager _cart = CartManager();

  @override
  void initState() {
    super.initState();
    _cart.addListener(_update);
  }

  @override
  void dispose() {
    _cart.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

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
                    child: _cart.items.isEmpty
                        ? const Center(
                            child: Text(
                              'Your cart is empty',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _cart.items.length,
                            itemBuilder: (context, index) {
                              final item = _cart.items[index];
                              return Card(
                                color: Colors.white.withOpacity(0.9),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: Image.asset(
                                    item.image,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(item.title),
                                  subtitle: Text(
                                    'Rs. ${item.price.toStringAsFixed(0)}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _cart.remove(item),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (_cart.items.isNotEmpty) ...[
                    Text(
                      'Total: Rs. ${_cart.total.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // directly pay total
                          PaymentManager.initiatePayment(context, _cart.total);
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
