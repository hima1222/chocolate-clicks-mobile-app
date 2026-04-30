import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/events_service.dart';
import 'package:chocolate_clicks/models/event_model.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  final EventsService _service = EventsService();
  List<EventModel> _events = [];
  bool _loading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final events = await _service.fetchUpcomingEvents();
    setState(() {
      _events = events;
      _loading = false;
    });
  }

  List<EventModel> get _filteredEvents {
    if (_selectedTab == 1) {
      final now = DateTime.now();
      return _events.where((event) {
        final difference = event.date.difference(now).inDays;
        return difference >= 0 && difference <= 7;
      }).toList();
    }
    if (_selectedTab == 2) {
      return _events.where((event) => true).toList();
    }
    return _events;
  }

  String _tabTitle(int index) {
    switch (index) {
      case 1:
        return 'This Week';
      case 2:
        return 'My RSVPs';
      default:
        return 'All Events';
    }
  }

  String _eventType(EventModel event) {
    final title = event.title.toLowerCase();
    if (title.contains('mask') || title.contains('workshop')) return 'Workshop';
    if (title.contains('tasting')) return 'Tasting';
    if (title.contains('bake')) return 'Baking';
    if (title.contains('picnic')) return 'Outdoor';
    return 'Experience';
  }

  String _eventAvailability(EventModel event) {
    final type = _eventType(event);
    if (type == 'Workshop') return '12 spots left';
    if (type == 'Tasting') return '8 spots only';
    if (type == 'Baking') return 'Beginner friendly';
    if (type == 'Outdoor') return 'Open to all — bring a friend!';
    return 'Reserve your spot';
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;

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
                    'Upcoming Events',
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
                    Row(
                      children: List.generate(3, (index) {
                        final selected = index == _selectedTab;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = index),
                            child: Container(
                              margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: selected
                                    ? const Color(0xFFEF5350)
                                    : const Color(0xFF2A1212),
                              ),
                              child: Center(
                                child: Text(
                                  _tabTitle(index),
                                  style: TextStyle(
                                    color: selected ? Colors.white : Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              else if (events.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F0A0A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    _selectedTab == 2
                        ? 'You have no RSVPs yet. Browse events to save your seat.'
                        : 'No upcoming events found.',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Column(
                  children: events.map((event) => _buildEventCard(event)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final type = _eventType(event);
    final availability = _eventAvailability(event);
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
            width: 74,
            padding: const EdgeInsets.symmetric(vertical: 20),
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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  month,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'LKR ${event.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.white54),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    availability,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
