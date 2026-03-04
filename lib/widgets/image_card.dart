// lib/widgets/image_card.dart
import 'package:flutter/material.dart';
import '../services/payment_manager.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class ProductCard extends StatelessWidget {
  final String imageAsset;
  final String title;
  final double rating;
  final int reviewCount;
  final double price;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.rating,
    required this.reviewCount,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.asset(
                imageAsset,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '$rating ($reviewCount)',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 230, 81, 0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            PaymentManager.initiatePayment(context, price);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              245,
                              157,
                              74,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Buy Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            CartService().addOrUpdateItem(
                              CartItem(
                                id: imageAsset, // Use image path as unique ID
                                name: title,
                                price: price,
                                quantity: 1,
                                imageUrl: imageAsset,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart')),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          color: Colors.brown,
                        ),
                      ),
                    ],
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
