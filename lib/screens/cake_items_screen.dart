// lib/screens/cake_items_screen.dart
import 'package:flutter/material.dart';
import '../widgets/image_card.dart';

class CakeItemsScreen extends StatelessWidget {
  const CakeItemsScreen({super.key});

  static final List<Map<String, dynamic>> cakeProducts = [
    {'image': 'assets/images/cake1.jpg', 'title': 'Lorem ipsum', 'rating': 9.0, 'reviews': 15, 'price': 3500.0},
    {'image': 'assets/images/cake2.jpg', 'title': 'Lorem ipsum', 'rating': 8.5, 'reviews': 20, 'price': 3800.0},
    {'image': 'assets/images/cake3.jpg', 'title': 'Lorem ipsum', 'rating': 9.2, 'reviews': 18, 'price': 3500.0},
    {'image': 'assets/images/cake4.jpg', 'title': 'Lorem ipsum', 'rating': 8.8, 'reviews': 25, 'price': 3500.0},
    {'image': 'assets/images/cake5.jpg', 'title': 'Lorem ipsum', 'rating': 9.1, 'reviews': 12, 'price': 4200.0},
    {'image': 'assets/images/cake6.jpg', 'title': 'Lorem ipsum', 'rating': 8.7, 'reviews': 30, 'price': 3500.0},
    {'image': 'assets/images/cake7.jpg', 'title': 'Lorem ipsum', 'rating': 9.0, 'reviews': 22, 'price': 3800.0},
    {'image': 'assets/images/cake8.jpg', 'title': 'Lorem ipsum', 'rating': 8.9, 'reviews': 17, 'price': 3500.0},
    {'image': 'assets/images/cake9.jpg', 'title': 'Lorem ipsum', 'rating': 8.9, 'reviews': 17, 'price': 3500.0},
    {'image': 'assets/images/cake10.jpg', 'title': 'Lorem ipsum', 'rating': 8.9, 'reviews': 17, 'price': 3500.0},
    {'image': 'assets/images/cake11.jpg', 'title': 'Lorem ipsum', 'rating': 8.9, 'reviews': 17, 'price': 3500.0},


  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with centered black pill title
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
                      'Cake',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balances the back button space
                ],
              ),
            ),
            // Product grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.73, // Adjusted for good card proportions
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                ),
                itemCount: cakeProducts.length,
                itemBuilder: (context, index) {
                  final product = cakeProducts[index];
                  return ProductCard(
                    imageAsset: product['image'],
                    title: product['title'],
                    rating: product['rating'],
                    reviewCount: product['reviews'],
                    price: product['price'],
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