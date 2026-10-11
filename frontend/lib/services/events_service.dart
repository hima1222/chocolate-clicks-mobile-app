import 'package:chocolate_clicks/models/event_model.dart';
import 'package:chocolate_clicks/services/api_client.dart';
import 'package:chocolate_clicks/services/auth_service.dart';

/// Service for fetching and managing events
class EventsService {
  static final EventsService _instance = EventsService._internal();
  factory EventsService() => _instance;
  EventsService._internal();

  final List<EventModel> _events = [];

  /// Fetch upcoming events for the user
  Future<List<EventModel>> fetchUpcomingEvents() async {
    final token = AuthService().authToken;
    final response = await ApiClient().get(
      '/events',
      headers: token == null ? null : {'Authorization': 'Bearer $token'},
    );
    if (response['success'] != true) {
      throw ApiException(
        message: response['message'] as String? ?? 'Failed to fetch events',
      );
    }
    final data = response['data'];
    if (data is! List) {
      throw ApiException(message: 'Invalid events response');
    }
    _events
      ..clear()
      ..addAll(
        data
            .whereType<Map<String, dynamic>>()
            .map(EventModel.fromJson),
      );
    return List.unmodifiable(_events);
  }

  /// Clear event list (on logout)
  void clear() => _events.clear();
}
