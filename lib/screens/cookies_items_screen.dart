// lib/screens/cookies_items_screen.dart
import 'package:flutter/material.dart';
import '../widgets/image_card.dart';
import 'cookies_type1.dart';

class CookiesItemsScreen extends StatelessWidget {
  const CookiesItemsScreen({super.key});

  static final List<Map<String, dynamic>> cookieProducts = [
    {
      'image': 'assets/images/cookies1.jpg',
      'title': 'Lorem ipsum',
      'rating': 9.0,
      'reviews': 18,
      'price': 3500.0,
    },
    {
      'image': 'assets/images/cookies2.jpg',
      'title': 'Lorem ipsum',
      'rating': 8.7,
      'reviews': 25,
      'price': 3200.0,
    },
    {
      'image': 'assets/images/cookies3.jpg',
      'title': 'Lorem ipsum',
      'rating': 9.1,
      'reviews': 15,
      'price': 3500.0,
    },
    {
      'image': 'assets/images/cookies4.jpg',
      'title': 'Lorem ipsum',
      'rating': 8.9,
      'reviews': 20,
      'price': 3800.0,
    },
    {
      'image': 'assets/images/cookies5.jpg',
      'title': 'Lorem ipsum',
      'rating': 9.0,
      'reviews': 12,
      'price': 3500.0,
    },
    {
      'image': 'assets/images/cookies6.jpg',
      'title': 'Lorem ipsum',
      'rating': 8.8,
      'reviews': 30,
      'price': 3500.0,
    },
    {
      'image': 'assets/images/cookies7.jpg',
      'title': 'Lorem ipsum',
      'rating': 9.2,
      'reviews': 22,
      'price': 3800.0,
    },
    {
      'image': 'assets/images/cookies8.jpg',
      'title': 'Lorem ipsum',
      'rating': 9.2,
      'reviews': 22,
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
              'assets/images/cookies_type1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xE614110F), Color(0xF02D1F17)],
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
                          'Cookies Collection',
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
                          '8 items',
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
                      childAspectRatio: 1.05,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CookiesType1Screen(),
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
