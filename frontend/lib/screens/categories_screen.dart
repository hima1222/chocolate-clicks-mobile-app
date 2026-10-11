import 'package:flutter/material.dart';
import '../widgets/shop_page.dart';
import '../widgets/compact_shop_grid.dart';
import 'cake_items_screen.dart';
import 'brownies_items_screen.dart';
import 'cookies_items_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        [
              (
                title: 'Cakes',
                description:
                    'Celebration-ready layers and everyday favourites.',
                image: 'assets/images/cake1.jpg',
                count: CakeItemsScreen.cakeProducts.length,
                route: '/cake',
              ),
              (
                title: 'Brownies',
                description:
                    'Rich chocolate, fudgy centres, and little moments of joy.',
                image: 'assets/images/brownies1.jpg',
                count: BrowniesItemsScreen.brownieProducts.length,
                route: '/brownies',
              ),
              (
                title: 'Cookies',
                description:
                    'Golden edges and comforting bites, made for sharing.',
                image: 'assets/images/cookies1.jpg',
                count: CookiesItemsScreen.cookieProducts.length,
                route: '/cookies',
              ),
            ]
            .where(
              (c) => c.title.toLowerCase().contains(
                _search.text.trim().toLowerCase(),
              ),
            )
            .toList();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/welcome_profile');
        }
      },
      child: ShopPage(
        title: 'Categories',
        subtitle:
            'Find your next sweet favourite. Explore our collection, one delicious bite at a time.',
        onBack: () =>
            Navigator.pushReplacementNamed(context, '/welcome_profile'),
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: shopCream),
            decoration: shopInput('Search categories', Icons.search).copyWith(
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close, color: shopCream),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          if (categories.isEmpty)
            const ShopPanel(
              child: Column(
                children: [
                  Icon(Icons.search_off, color: shopGold, size: 42),
                  SizedBox(height: 12),
                  Text(
                    'No categories found',
                    style: TextStyle(color: shopCream, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try cakes, brownies, or cookies.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          CompactShopGrid(
            children: [
              for (final category in categories)
                CompactShopCard(
                  title: category.title,
                  image: category.image,
                  description: category.description,
                  label: '${category.count} treats',
                  onTap: () => Navigator.pushNamed(context, category.route),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
