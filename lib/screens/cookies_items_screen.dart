// lib/screens/cookies_items_screen.dart
import 'package:flutter/material.dart';
import '../widgets/image_card.dart';

class CookiesItemsScreen extends StatelessWidget {
  const CookiesItemsScreen({super.key});

  static final List<Map<String, dynamic>> cookieProducts = [
    {'image': 'assets/images/cookies1.jpg', 'title': 'Lorem ipsum', 'rating': 9.0, 'reviews': 18, 'price': 3500.0},
    {'image': 'assets/images/cookies2.jpg', 'title': 'Lorem ipsum', 'rating': 8.7, 'reviews': 25, 'price': 3200.0},
    {'image': 'assets/images/cookies3.jpg', 'title': 'Lorem ipsum', 'rating': 9.1, 'reviews': 15, 'price': 3500.0},
    {'image': 'assets/images/cookies4.jpg', 'title': 'Lorem ipsum', 'rating': 8.9, 'reviews': 20, 'price': 3800.0},
    {'image': 'assets/images/cookies5.jpg', 'title': 'Lorem ipsum', 'rating': 9.0, 'reviews': 12, 'price': 3500.0},
    {'image': 'assets/images/cookies6.jpg', 'title': 'Lorem ipsum', 'rating': 8.8, 'reviews': 30, 'price': 3500.0},
    {'image': 'assets/images/cookies7.jpg', 'title': 'Lorem ipsum', 'rating': 9.2, 'reviews': 22, 'price': 3800.0},
    {'image': 'assets/images/cookies8.jpg', 'title': 'Lorem ipsum', 'rating': 9.2, 'reviews': 22, 'price': 3800.0},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Cookies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.73,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                ),
                itemCount: cookieProducts.length,
                itemBuilder: (context, index) {
                  final product = cookieProducts[index];
                  return ProductCard(
                    imageAsset: product['image'],
                    title: product['title'],
                    rating: product['rating'],
                    reviewCount: product['reviews'],
                    price: product['price'],
                    onTap: () {
                      Navigator.pushNamed(context, '/cookies_type1');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}