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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF241A14).withValues(alpha: 0.92),
        border: Border.all(color: const Color(0x66F6E6D7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.asset(
                  imageAsset,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFF6E6D7),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF8B84E), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          '$rating ($reviewCount)',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs. ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFF8B84E),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 28,
                            child: ElevatedButton(
                              onPressed: () {
                                PaymentManager.initiatePayment(context, price);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFFCA7A2B),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: const Text(
                                'Buy Now',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(9),
                          ),
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
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              size: 18,
                              color: Color(0xFFF6E6D7),
                            ),
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
      ),
    );
  }
}
