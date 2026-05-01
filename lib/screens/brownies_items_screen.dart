// lib/screens/brownies_items_screen.dart
import 'package:flutter/material.dart';
import '../widgets/image_card.dart';
import 'brownies_type1.dart';

class BrowniesItemsScreen extends StatelessWidget {
  const BrowniesItemsScreen({super.key});

  static final List<Map<String, dynamic>> brownieProducts = [
    {
      'image': 'assets/images/brownies1.jpg',
      'title': 'Lorem ipsum',
      'rating': 9.0,
      'reviews': 15,
      'price': 3500.0,
    },
    {
      'image': 'assets/images/brownies2.jpg',
      'title': 'Lorem ipsum',
      'rating': 8.8,
      'reviews': 22,
      'price': 3800.0,
    },
    {
      'image': 'assets/images/brownies3.jpg',
      'title': 'Lorem ipsum',
      'rating': 9.2,
      'reviews': 18,
      'price': 3500.0,
    },
    {
      'image': 'assets/images/brownies4.jpg',
      'title': 'Lorem ipsum',
      'rating': 8.5,
      'reviews': 30,
      'price': 3200.0,
    },
    {
      'image': 'assets/images/brownies5.jpg',
      'title': 'Lorem ipsum',
      'rating': 9.1,
      'reviews': 12,
      'price': 3500.0,
    },
    {
      'image': 'assets/images/brownies6.jpg',
      'title': 'Lorem ipsum',
      'rating': 8.9,
      'reviews': 25,
      'price': 3800.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/brownies_type1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xE615110F), Color(0xF0302017)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFFF6E6D7),
                            size: 24,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Brownies Collection',
                          style: TextStyle(
                            color: Color(0xFFF6E6D7),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Text(
                          '6 items',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
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
        ],
      ),
    );
  }
}
