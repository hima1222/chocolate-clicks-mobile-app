import 'package:chocolate_clicks/models/product_model.dart';
import 'package:chocolate_clicks/services/api_client.dart';

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
      // For now, return mock categories since backend doesn't have categories endpoint
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
      final response = await ApiClient().get('/products/category/$categoryId');
      if (response['success'] == true) {
        final products = (response['data'] as List)
            .map((p) => Product.fromJson(p))
            .toList();
        return products;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch products');
      }
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Fetch single product by ID
  Future<Product?> fetchProductById(String id) async {
    try {
      final response = await ApiClient().get('/products/$id');
      if (response['success'] == true) {
        return Product.fromJson(response['data']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Search products by name or description
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await ApiClient().get('/products/search?q=$query');
      if (response['success'] == true) {
        final products = (response['data'] as List)
            .map((p) => Product.fromJson(p))
            .toList();
        return products;
      } else {
        throw Exception(response['message'] ?? 'Search failed');
      }
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
