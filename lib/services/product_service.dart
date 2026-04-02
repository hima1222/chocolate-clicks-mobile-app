import 'package:chocolate_clicks/models/product_model.dart';

/// Service for managing product catalog and search
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final List<Product> _products = [];
  final List<Category> _categories = [];

  /// Fetch all categories
  Future<List<Category>> fetchCategories() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: Replace with API call
      if (_categories.isEmpty) {
        _categories.addAll([
          Category(
            id: 'cat_1',
            name: 'Cakes',
            imageUrl: 'assets/images/cake.jpg',
            description: 'Delicious fresh cakes',
          ),
          Category(
            id: 'cat_2',
            name: 'Brownies',
            imageUrl: 'assets/images/brownies.jpg',
            description: 'Rich chocolate brownies',
          ),
          Category(
            id: 'cat_3',
            name: 'Cookies',
            imageUrl: 'assets/images/cookies.jpg',
            description: 'Fresh baked cookies',
          ),
        ]);
      }
      return List.unmodifiable(_categories);
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      // TODO: Replace with API call
      return _products.where((p) => p.categoryId == categoryId).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Fetch single product by ID
  Future<Product?> fetchProductById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      // TODO: Replace with API call
      return _products.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Product not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Search products by name or description
  Future<List<Product>> searchProducts(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      // TODO: Replace with API call
      final q = query.toLowerCase();
      return _products
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q),
          )
          .toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  /// Add mock product (for testing)
  void addProduct(Product product) {
    if (!_products.any((p) => p.id == product.id)) {
      _products.add(product);
    }
  }

  /// Clear all products (on logout)
  void clear() {
    _products.clear();
  }
}
