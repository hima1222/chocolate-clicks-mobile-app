import 'package:chocolate_clicks/models/event_model.dart';

/// Service for fetching and managing events
class EventsService {
  static final EventsService _instance = EventsService._internal();
  factory EventsService() => _instance;
  EventsService._internal();

  final List<EventModel> _events = [];

  /// Fetch upcoming events for the user
  Future<List<EventModel>> fetchUpcomingEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_events);
  }

  /// Add a new event to mock list
  Future<void> addEvent(EventModel event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _events.add(event);
  }

  /// Clear event list (on logout)
  void clear() => _events.clear();
}
