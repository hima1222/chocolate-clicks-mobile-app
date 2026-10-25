import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/events_service.dart';
import 'event_detail_page.dart';
import 'event_booking_button.dart';
import 'shop_page.dart';

class ScheduledEventPage extends StatefulWidget {
  final String title, subtitle, image, description;
  final List<String> gallery, included, details;
  final Future<List<EventModel>> Function()? loadSessions;

  const ScheduledEventPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.description,
    required this.gallery,
    required this.included,
    this.details = const [],
    this.loadSessions,
  });

  @override
  State<ScheduledEventPage> createState() => _ScheduledEventPageState();
}

class _ScheduledEventPageState extends State<ScheduledEventPage>
    with WidgetsBindingObserver {
  late Future<List<EventModel>> _sessions;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessions = _load();
  }

  Future<List<EventModel>> _load() async {
    final events =
        await (widget.loadSessions?.call() ??
            EventsService().fetchUpcomingEvents());
    final now = DateTime.now();
    return events
        .where(
          (event) =>
              event.title.trim().toLowerCase() ==
                  widget.title.trim().toLowerCase() &&
              event.date.isAfter(now),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _refresh() => setState(() {
    _selectedId = null;
    _sessions = _load();
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _hasSeats(EventModel event) =>
      event.capacity <= 0 || event.remainingSeats > 0;

  String _date(DateTime value) {
    final local = value.toLocal();
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
    return '${local.day} ${months[local.month - 1]} ${local.year}, ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<EventModel>>(
    future: _sessions,
    builder: (context, snapshot) {
      final loading = snapshot.connectionState != ConnectionState.done;
      final sessions = snapshot.data ?? <EventModel>[];
      EventModel? selected;
      for (final event in sessions) {
        if (event.id == _selectedId) selected = event;
      }
      selected ??=
          sessions.where(_hasSeats).firstOrNull ?? sessions.firstOrNull;
      final session = selected;
      final enabled =
          !loading &&
          !snapshot.hasError &&
          session != null &&
          _hasSeats(session);
      return EventDetailPage(
        title: widget.title,
        subtitle: widget.subtitle,
        image: widget.image,
        gallery: widget.gallery,
        description: widget.description,
        included: widget.included,
        details: widget.details,
        sessionDetails: ShopPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading)
                const Text(
                  'Checking future sessions...',
                  style: TextStyle(color: shopCream),
                )
              else if (snapshot.hasError)
                const Text(
                  'Unable to check sessions. Please try again.',
                  style: TextStyle(color: shopCream),
                )
              else if (session == null)
                const Text(
                  'No sessions are currently scheduled for this event. We will update you soon.',
                  style: TextStyle(color: shopCream, height: 1.5),
                )
              else ...[
                if (sessions.length > 1)
                  DropdownButtonFormField<String>(
                    key: ValueKey(session.id),
                    initialValue: session.id,
                    isExpanded: true,
                    dropdownColor: shopSurface,
                    decoration: shopInput(
                      'Choose a session',
                      Icons.calendar_month,
                    ),
                    items: [
                      for (final event in sessions)
                        DropdownMenuItem(
                          value: event.id,
                          child: Text(
                            _date(event.date),
                            style: const TextStyle(
                              color: shopCream,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                    onChanged: (id) => setState(() => _selectedId = id),
                  )
                else
                  Text(
                    'Next session: ${_date(session.date)}',
                    style: const TextStyle(color: shopGold, height: 1.5),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Price: Rs. ${session.price.toStringAsFixed(0)} per person',
                  style: const TextStyle(color: shopCream),
                ),
                const SizedBox(height: 8),
                Text(
                  'Location: ${session.location}',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (session.duration.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Duration: ${session.duration}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _hasSeats(session)
                      ? (session.capacity > 0
                            ? '${session.remainingSeats} seats available'
                            : 'Booking available')
                      : 'This session is fully booked.',
                  style: const TextStyle(color: shopGold),
                ),
              ],
              TextButton.icon(
                onPressed: loading ? null : _refresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(snapshot.hasError ? 'Retry' : 'Refresh sessions'),
                style: TextButton.styleFrom(foregroundColor: shopGold),
              ),
            ],
          ),
        ),
        bottomAction: EventBookingButton(
          key: ValueKey(session?.id),
          eventTitle: widget.title,
          eventId: session?.id,
          enabled: enabled,
        ),
      );
    },
  );
}
