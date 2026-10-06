import 'package:chocolate_clicks/services/api_client.dart';
import 'package:chocolate_clicks/services/auth_service.dart';

/// Booking model for frontend
class Booking {
  final String id;
  final String eventId;
  final String eventTitle;
  final DateTime eventDate;
  final String eventLocation;
  final double eventPrice;
  final int seats;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventLocation,
    required this.eventPrice,
    required this.seats,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final event = json['eventId'] ?? json['event'];
    final eventMap = event is Map<String, dynamic> ? event : <String, dynamic>{};
    final rawEventId = event is String ? event : eventMap['_id'] ?? eventMap['id'];
    final rawEventDate = eventMap['startDate'] ?? eventMap['date'];
    final rawCreatedAt = json['createdAt'];
    return Booking(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      eventId: rawEventId?.toString() ?? '',
      eventTitle: eventMap['title']?.toString() ?? 'Untitled event',
      eventDate: DateTime.tryParse(rawEventDate?.toString() ?? '') ?? DateTime.now(),
      eventLocation: eventMap['location']?.toString() ?? '',
      eventPrice: ((eventMap['price'] as num?) ?? 0).toDouble(),
      seats: (json['seats'] as num?)?.toInt() ?? 1,
      status: json['status']?.toString() ?? 'confirmed',
      createdAt: DateTime.tryParse(rawCreatedAt?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Service for managing event bookings
class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  /// Create a new booking
  Future<Booking> createBooking({
    required String eventId,
    required int seats,
    String? notes,
  }) async {
    try {
      final authService = AuthService();
      final token = authService.authToken;
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await ApiClient().post('/bookings', body: {
        'eventId': eventId,
      }, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response['success'] == true) {
        return Booking.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Get user's bookings
  Future<List<Booking>> getUserBookings() async {
    try {
      final authService = AuthService();
      final token = authService.authToken;
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await ApiClient().get('/bookings/me', headers: {
        'Authorization': 'Bearer $token',
      });

      if (response['success'] == true) {
        final bookings = (response['data'] as List)
            .map((b) => Booking.fromJson(b))
            .toList();
        return bookings;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch bookings');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  /// Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final authService = AuthService();
      final token = authService.authToken;
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await ApiClient().get('/bookings/$bookingId', headers: {
        'Authorization': 'Bearer $token',
      });

      if (response['success'] == true) {
        return Booking.fromJson(response['data']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}