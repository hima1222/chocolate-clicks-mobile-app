import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/events_service.dart';
import 'package:chocolate_clicks/models/event_model.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventsService _eventsService = EventsService();
  late List<EventModel> _events = [
    EventModel(
      id: 'evt_1',
      title: 'Mask Painting Workshop',
      description: 'Join us for a creative and fun workshop where you wll paint decorative masks.',
      date: DateTime(2026, 5, 8),
      location: 'LKR',
      price: 1500.0,
      imageUrl: 'assets/images/mask_painting.jpg',
    ),
    EventModel(
      id: 'evt_2',
      title: 'Tasting LUXE',
      description: 'Exclusive tasting event featuring our premium chocolate and dessert collection.',
      date: DateTime(2026, 5, 14),
      location: 'Colombo',
      price: 2200.0,
      imageUrl: 'assets/images/tasting_luxe.jpg',
    ),
    EventModel(
      id: 'evt_3',
      title: 'Bake It Happen',
      description: 'Learn baking basics from our expert chefs in this beginner-friendly class.',
      date: DateTime(2026, 5, 21),
      location: 'Kandy',
      price: 1800.0,
      imageUrl: 'assets/images/bake_it_happen.jpg',
    ),
    EventModel(
      id: 'evt_4',
      title: 'Summer Cake Picnic',
      description: 'Celebrate summer with outdoor picnic featuring fresh cakes and treats.',
      date: DateTime(2026, 5, 28),
      location: 'Negombo Beach',
      price: 0.0,
      imageUrl: 'assets/images/summer_picnic.jpg',
    ),
  ];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventsService.fetchUpcomingEvents();
      if (events.isNotEmpty) {
        setState(() {
          _events = events;
        });
      }
    } catch (_) {
      // Use default mock events
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _eventType(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('mask') || lower.contains('workshop')) return 'Workshop';
    if (lower.contains('tasting')) return 'Tasting';
    if (lower.contains('bake')) return 'Baking';
    if (lower.contains('picnic')) return 'Outdoor';
    return 'Experience';
  }

  String _eventUrgency(String title) {
    final type = _eventType(title);
    if (type == 'Workshop') return '12 spots left — tap to reserve';
    if (type == 'Tasting') return 'Exclusive — 8 spots only';
    if (type == 'Baking') return 'Beginner friendly';
    if (type == 'Outdoor') return 'Open to all — bring a friend!';
    return 'Reserve your spot';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120101),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Events',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A0A0A), Color(0xFF120101)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sweeten your day with Chocolate Clicks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _loading ? 'Loading events...' : '${_events.length} events coming up',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else if (_events.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F0A0A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Text(
                    'No events scheduled yet. Check back soon!',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Column(
                  children: _events.map((event) => _buildEventCard(event)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final type = _eventType(event.title);
    final urgency = _eventUrgency(event.title);
    final day = event.date.day.toString();
    final month = _monthAbbreviation(event.date.month);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F0A0A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFF2F1515),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  month,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (event.price > 0)
                        Text(
                          'LKR ${event.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        const Text(
                          'Free',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    urgency,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
