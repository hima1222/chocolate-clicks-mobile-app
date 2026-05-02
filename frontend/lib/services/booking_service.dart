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
    return Booking(
      id: json['_id'] ?? json['id'],
      eventId: json['event']['_id'] ?? json['event']['id'],
      eventTitle: json['event']['title'],
      eventDate: DateTime.parse(json['event']['date']),
      eventLocation: json['event']['location'],
      eventPrice: (json['event']['price'] as num).toDouble(),
      seats: json['seats'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
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
        'seats': seats,
        'notes': notes,
      }, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response['success'] == true) {
        return Booking.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
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

      final response = await ApiClient().get('/bookings', headers: {
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