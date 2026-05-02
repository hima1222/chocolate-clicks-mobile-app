import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/favorites_service.dart';
import 'package:chocolate_clicks/services/cart_service.dart';
import 'package:chocolate_clicks/models/cart_item.dart';
//import 'package:chocolate_clicks/models/favorite_item.dart';

class BrowniesType1Screen extends StatefulWidget {
  final Map<String, dynamic>? product;
  final int? index;

  const BrowniesType1Screen({super.key, this.product, this.index});

  @override
  State<BrowniesType1Screen> createState() => _BrowniesType1ScreenState();
}

class _BrowniesType1ScreenState extends State<BrowniesType1Screen> {
  String selectedSize = 'Medium';
  String selectedTopping = 'Nuts';
  String selectedFrosting = 'Chocolate';
  bool isFavorite = false;
  final FavoritesService _favoritesService = FavoritesService();
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    final productTitle = widget.product?['title'] as String? ?? 'Brownies Type 1';
    final productImage = widget.product?['image'] as String? ?? 'assets/images/brownies_type1.jpg';
    final productPrice = widget.product?['price'] as double? ?? 3500.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                            productTitle,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 28,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => setState(() => isFavorite = !isFavorite),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      productImage,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LKR ${productPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.product?['rating']?.toString() ?? '9.0',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${widget.product?['reviews'] ?? 15} reviews)',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Rich, fudgy brownies with premium ingredients. Perfect for chocolate lovers.',
                            style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Size', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 50),
                            child: DropdownButton<String>(
                              value: selectedSize,
                              isExpanded: true,
                              isDense: true,
                              underline: Container(),
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              items: ['Small', 'Medium', 'Large'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(value),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => selectedSize = value!),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Toppings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 50),
                            child: DropdownButton<String>(
                              value: selectedTopping,
                              isExpanded: true,
                              isDense: true,
                              underline: Container(),
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              items: ['Nuts', 'Chocolate Chips', 'Caramel', 'Sea Salt'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(value),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => selectedTopping = value!),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Frosting', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 50),
                            child: DropdownButton<String>(
                              value: selectedFrosting,
                              isExpanded: true,
                              isDense: true,
                              underline: Container(),
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              items: ['Chocolate', 'Vanilla', 'Cream Cheese', 'None'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(value),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => selectedFrosting = value!),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 67, 67, 67),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final item = CartItem(
                          id: 'brownies_${widget.index ?? 0}',
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
