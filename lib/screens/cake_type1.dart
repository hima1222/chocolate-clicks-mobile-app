import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/favorites_service.dart';
import 'package:chocolate_clicks/services/cart_service.dart';
import 'package:chocolate_clicks/models/cart_item.dart';
import 'package:chocolate_clicks/models/favorite_item.dart';

class CakeType1Screen extends StatefulWidget {
  final Map<String, dynamic>? product;
  final int? index;

  const CakeType1Screen({super.key, this.product, this.index});

  @override
  State<CakeType1Screen> createState() => _CakeType1ScreenState();
}

class _CakeType1ScreenState extends State<CakeType1Screen> {
  Map<String, dynamic>? get product => widget.product;

  String selectedSize = 'Medium';
  String selectedTopping = 'Blueberry & Lemon';
  String selectedFrosting = 'Chocolate';
  bool isFavorite = false;
  final FavoritesService _favoritesService = FavoritesService();
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    final productTitle = widget.product?['title'] ?? 'Blue Berry Cake';
    final productImage = widget.product?['image'] ?? 'assets/images/cake_type1.jpg';
    final productPrice = widget.product?['price'] ?? 4500.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      product?['title'] as String? ?? 'Blue Berry Cake',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Image.asset(
                product?['image'] as String? ?? 'assets/images/cake_type1.jpg',
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product?['description'] as String? ??
                      'Light sponge cake finished with a bright fruity topping.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedSize,
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: ['Small', 'Medium', 'Large'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedSize = value!),
                    ),

                    const SizedBox(height: 20),
                    const Text('Toppings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedTopping,
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: ['Blueberry & Lemon', 'Chocolate Chips', 'Nuts'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedTopping = value!),
                    ),

                    const SizedBox(height: 20),
                    const Text('Frosting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedFrosting,
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: ['Chocolate', 'Vanilla', 'Cream Cheese'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedFrosting = value!),
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reviews coming soon!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[800],
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Review', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.grey[900],
                child: Text(
                  product?['description'] as String? ??
                      'A fresh cake built for a bright and balanced flavor profile.',
                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final item = CartItem(
                          id: 'cake_${widget.index ?? 0}',
                          name: productTitle,
                          price: productPrice,
                          quantity: 1,
                          imageUrl: productImage,
                        );
                        await _cartService.addOrUpdateItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Proceeding to checkout...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Buy Now', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
