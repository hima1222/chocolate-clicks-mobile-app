import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/events_service.dart';
import '../widgets/shop_page.dart';
import '../widgets/compact_shop_grid.dart';
import '../widgets/event_detail_page.dart';
import '../widgets/event_booking_button.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<EventModel>> _events;
  @override
  void initState() {
    super.initState();
    _events = EventsService().fetchUpcomingEvents();
  }

  Future<void> _open(EventModel event) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EventDetailPage(
          title: event.title,
          subtitle: event.subtitle,
          image: event.imageUrl,
          gallery: event.gallery,
          description: event.description,
          included: event.included,
          details: [
            if (event.duration.isNotEmpty) 'Duration: ${event.duration}',
            'Price: Rs. ${event.price.toStringAsFixed(0)} per person',
            if (event.schedule.isNotEmpty) 'Schedule: ${event.schedule}',
            'Next session: ${event.date.toLocal()}',
            'Location: ${event.location}',
            'Available seats: ${event.remainingSeats}',
          ],
          bottomAction: EventBookingButton(
            eventTitle: event.title,
            eventId: event.id,
          ),
        ),
      ),
    );
    if (mounted) {
      setState(() => _events = EventsService().fetchUpcomingEvents());
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) Navigator.pushReplacementNamed(context, '/welcome_profile');
    },
    child: ShopPage(
      title: 'Events',
      subtitle: 'Explore experiences at Chocolate Clicks',
      onBack: () => Navigator.pushReplacementNamed(context, '/welcome_profile'),
      children: [
        FutureBuilder<List<EventModel>>(
          future: _events,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Column(
                children: [
                  const Text(
                    'Unable to load events. Please try again.',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _events = EventsService().fetchUpcomingEvents();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              );
            }
            final events = snapshot.data ?? [];
            if (events.isEmpty) {
              return const Text(
                'No upcoming events yet.',
                style: TextStyle(color: Colors.white),
              );
            }
            return CompactShopGrid(
              children: [
                for (final event in events)
                  CompactShopCard(
                    title: event.title,
                    image: event.cardImage.isEmpty
                        ? event.imageUrl
                        : event.cardImage,
                    label: 'View event',
                    onTap: () => _open(event),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
