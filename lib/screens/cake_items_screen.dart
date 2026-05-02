// lib/screens/cake_items_screen.dart
import 'package:flutter/material.dart';
import '../widgets/image_card.dart';
import 'cake_type1.dart';

class CakeItemsScreen extends StatelessWidget {
  const CakeItemsScreen({super.key});

  static final List<Map<String, dynamic>> cakeProducts = [
    {
      'image': 'assets/images/cake1.jpg',
      'title': 'Blueberry Lemon Cake',
      'rating': 9.0,
      'reviews': 15,
      'price': 3500.0,
      'description': 'Light sponge cake with blueberry topping and lemon glaze.',
    },
    {
      'image': 'assets/images/cake2.jpg',
      'title': 'Chocolate Truffle Cake',
      'rating': 8.5,
      'reviews': 20,
      'price': 3800.0,
      'description': 'Rich chocolate layers filled with silky truffle cream.',
    },
    {
      'image': 'assets/images/cake3.jpg',
      'title': 'Vanilla Rose Cake',
      'rating': 9.2,
      'reviews': 18,
      'price': 3500.0,
      'description': 'Classic vanilla cake finished with rose-flavored frosting.',
    },
    {
      'image': 'assets/images/cake4.jpg',
      'title': 'Black Forest Cake',
      'rating': 8.8,
      'reviews': 25,
      'price': 3500.0,
      'description': 'Chocolate sponge, cherries, and whipped cream in every layer.',
    },
    {
      'image': 'assets/images/cake5.jpg',
      'title': 'Caramel Drip Cake',
      'rating': 9.1,
      'reviews': 12,
      'price': 4200.0,
      'description': 'Soft caramel cake topped with a glossy caramel drip.',
    },
    {
      'image': 'assets/images/cake6.jpg',
      'title': 'Strawberry Dream Cake',
      'rating': 8.7,
      'reviews': 30,
      'price': 3500.0,
      'description': 'Fresh strawberry filling with a light cream finish.',
    },
    {
      'image': 'assets/images/cake7.jpg',
      'title': 'Pistachio Delight Cake',
      'rating': 9.0,
      'reviews': 22,
      'price': 3800.0,
      'description': 'Nutty pistachio layers with a smooth buttercream coat.',
    },
    {
      'image': 'assets/images/cake8.jpg',
      'title': 'Red Velvet Cake',
      'rating': 8.9,
      'reviews': 17,
      'price': 3500.0,
      'description': 'Soft red velvet sponge with cream cheese frosting.',
    },
    {
      'image': 'assets/images/cake9.jpg',
      'title': 'Mango Cream Cake',
      'rating': 8.9,
      'reviews': 17,
      'price': 3500.0,
      'description': 'Tropical mango cake finished with fresh cream.',
    },
    {
      'image': 'assets/images/cake10.jpg',
      'title': 'Coffee Mocha Cake',
      'rating': 8.9,
      'reviews': 17,
      'price': 3500.0,
      'description': 'A bold mocha cake with a smooth coffee aroma.',
    },
    {
      'image': 'assets/images/cake11.jpg',
      'title': 'White Forest Cake',
      'rating': 8.9,
      'reviews': 17,
      'price': 3500.0,
      'description': 'Delicate white chocolate cake with soft cream layers.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/cake_type1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xE614100D), Color(0xF02A1C14)],
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
                          'Cake Collection',
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
                          '11 items',
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
                    itemCount: cakeProducts.length,
                    itemBuilder: (context, index) {
                      final product = cakeProducts[index];
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
                              builder: (context) => CakeType1Screen(product: product),
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
