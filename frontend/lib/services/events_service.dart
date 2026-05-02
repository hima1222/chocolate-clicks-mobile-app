import 'package:chocolate_clicks/models/event_model.dart';
import 'package:chocolate_clicks/services/api_client.dart';

/// Service for fetching and managing events
class EventsService {
  static final EventsService _instance = EventsService._internal();
  factory EventsService() => _instance;
  EventsService._internal();

  final List<EventModel> _events = [];

  /// Fetch upcoming events for the user
  Future<List<EventModel>> fetchUpcomingEvents() async {
    try {
      final response = await ApiClient().get('/events');
      if (response['success'] == true) {
        final events = (response['data'] as List)
            .map((e) => EventModel.fromJson(e))
            .toList();
        return events;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch events');
      }
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  /// Add a new event to mock list
  Future<void> addEvent(EventModel event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _events.add(event);
  }

  /// Clear event list (on logout)
  void clear() => _events.clear();
}
