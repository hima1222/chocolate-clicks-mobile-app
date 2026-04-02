/// Represents an item saved as favourite by the user
class FavoriteItem {
  final String id;
  final String name;
  final String imageUrl;
  final String category;

  FavoriteItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'imageUrl': imageUrl, 'category': category};
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
    );
  }
}
