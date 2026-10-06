/// Represents an event that user can view or attend
class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final double price;
  final String imageUrl;
  final int capacity;
  final int bookedCount;
  final int remainingSeats;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.price,
    required this.imageUrl,
    this.capacity = 0,
    this.bookedCount = 0,
    this.remainingSeats = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': date.toIso8601String(),
      'location': location,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'];
    final rawDate = json['startDate'] ?? json['date'];
    return EventModel(
      id: rawId?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled event',
      description: json['description']?.toString() ?? '',
      date: DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
      location: json['location']?.toString() ?? 'Location unavailable',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      bookedCount: (json['bookedCount'] as num?)?.toInt() ?? 0,
      remainingSeats: (json['remainingSeats'] as num?)?.toInt() ?? 0,
    );
  }
}
