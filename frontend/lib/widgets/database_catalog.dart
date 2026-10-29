import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';

Map<String, dynamic> productCardData(Product p) => {
  'id': p.id,
  'title': p.name,
  'description': p.description,
  'image': p.imageUrl,
  'price': p.price,
  'quantity': p.quantity,
  'rating': p.rating,
  'reviews': p.reviewCount,
  'category': p.categoryId,
};

class DatabaseCatalog extends StatefulWidget {
  final String category;
  final Widget Function(BuildContext, List<Map<String, dynamic>>) builder;
  const DatabaseCatalog({
    super.key,
    required this.category,
    required this.builder,
  });
  @override
  State<DatabaseCatalog> createState() => _DatabaseCatalogState();
}

class _DatabaseCatalogState extends State<DatabaseCatalog> {
  late Future<List<Product>> _products;
  @override
  void initState() {
    super.initState();
    _products = ProductService().fetchProductsByCategory(widget.category);
  }

  Future<void> _refresh() async {
    final request = ProductService().fetchProductsByCategory(widget.category);
    setState(() => _products = request);
    await request;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Product>>(
    future: _products,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError || snapshot.data!.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.category)),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  snapshot.hasError
                      ? 'Unable to load products.'
                      : 'No products in this category.',
                ),
                TextButton(
                  onPressed: () {
                    _refresh();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: _refresh,
        child: widget.builder(
          context,
          snapshot.data!.map(productCardData).toList(),
        ),
      );
    },
  );
}
