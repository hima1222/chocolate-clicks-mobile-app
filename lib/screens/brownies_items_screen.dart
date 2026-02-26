// lib/screens/brownies_items_screen.dart
import 'package:flutter/material.dart';
import '../widgets/image_card.dart';
import 'brownies_type1.dart';

class BrowniesItemsScreen extends StatelessWidget {
  const BrowniesItemsScreen({super.key});

  static final List<Map<String, dynamic>> brownieProducts = [
    {'image': 'assets/images/brownies1.jpg', 'title': 'Lorem ipsum', 'rating': 9.0, 'reviews': 15, 'price': 3500.0},
    {'image': 'assets/images/brownies2.jpg', 'title': 'Lorem ipsum', 'rating': 8.8, 'reviews': 22, 'price': 3800.0},
    {'image': 'assets/images/brownies3.jpg', 'title': 'Lorem ipsum', 'rating': 9.2, 'reviews': 18, 'price': 3500.0},
    {'image': 'assets/images/brownies4.jpg', 'title': 'Lorem ipsum', 'rating': 8.5, 'reviews': 30, 'price': 3200.0},
    {'image': 'assets/images/brownies5.jpg', 'title': 'Lorem ipsum', 'rating': 9.1, 'reviews': 12, 'price': 3500.0},
    {'image': 'assets/images/brownies6.jpg', 'title': 'Lorem ipsum', 'rating': 8.9, 'reviews': 25, 'price': 3800.0},
   
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
                      'Brownies',
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
                itemCount: brownieProducts.length,
                itemBuilder: (context, index) {
                  final product = brownieProducts[index];
                  return ProductCard(
                    imageAsset: product['image'],
                    title: product['title'],
                    rating: product['rating'],
                    reviewCount: product['reviews'],
                    price: product['price'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BrowniesType1Screen(),
                        ),
                      );
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
