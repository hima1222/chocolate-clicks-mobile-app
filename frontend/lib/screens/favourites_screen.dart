import 'package:flutter/material.dart';
import '../widgets/shop_page.dart';
import '../services/favorites_service.dart';
import '../models/favorite_item.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});
  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final _service = FavoritesService();
  List<FavoriteItem> _items = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _service.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _service.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final items = await _service.fetchFavorites();
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => ShopPage(
    title: 'Favourites',
    subtitle:
        'Your own little collection of sweetness. Save the treats you love and find them here.',
    children: [
      ShopPanel(
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: shopGold,
              child: Icon(Icons.favorite, color: shopBackground),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Favourites',
                    style: TextStyle(
                      color: shopCream,
                      fontSize: 22,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _loading
                        ? 'Gathering your favourites...'
                        : '${_items.length} saved ${_items.length == 1 ? 'treat' : 'treats'}',
                    style: const TextStyle(color: shopGold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      if (_loading)
        const Center(child: CircularProgressIndicator(color: shopGold))
      else if (_items.isEmpty)
        ShopPanel(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.favorite_border, color: shopGold, size: 64),
              const SizedBox(height: 20),
              const Text(
                'No favourites yet',
                style: TextStyle(
                  color: shopCream,
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tap the heart on any treat to keep it in your collection.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.6),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/categories'),
                style: FilledButton.styleFrom(
                  backgroundColor: shopGold,
                  foregroundColor: shopBackground,
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Explore treats'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        )
      else
        for (final item in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: shopSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: shopGold.withValues(alpha: 0.18)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 88,
                        height: 100,
                        child: item.imageUrl.startsWith('assets/')
                            ? Image.asset(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _imageFallback(),
                              )
                            : Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _imageFallback(),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.category,
                            style: const TextStyle(
                              color: shopGold,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: shopCream,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Saved for later',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove from favourites',
                      onPressed: () => _service.removeFavorite(item.id),
                      icon: const Icon(Icons.delete, color: shopGold, size: 21),
                    ),
                  ],
                ),
              ),
            ),
          ),
    ],
  );

  Widget _imageFallback() => const ColoredBox(
    color: shopBackground,
    child: Icon(Icons.cake_outlined, color: shopGold, size: 36),
  );
}
