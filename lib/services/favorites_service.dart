import 'package:chocolate_clicks/models/favorite_item.dart';

/// Service managing user's favourites list
class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  // in-memory list for mock data
  final List<FavoriteItem> _favorites = [];

  /// Get all favourite items for the current user
  Future<List<FavoriteItem>> fetchFavorites() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_favorites);
  }

  /// Add an item to favourites
  Future<void> addFavorite(FavoriteItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_favorites.any((f) => f.id == item.id)) {
      _favorites.add(item);
    }
  }

  /// Remove an item from favourites by id
  Future<void> removeFavorite(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _favorites.removeWhere((f) => f.id == itemId);
  }

  /// Clear all favourites (e.g. on logout)
  void clear() {
    _favorites.clear();
  }
}
