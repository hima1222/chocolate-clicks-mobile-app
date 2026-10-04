import 'package:flutter/material.dart';
import 'package:chocolate_clicks/models/event_model.dart';
import 'package:chocolate_clicks/services/auth_service.dart';
import 'package:chocolate_clicks/services/booking_service.dart';
import 'package:chocolate_clicks/services/events_service.dart';

class EventBookingButton extends StatefulWidget {
  const EventBookingButton({
    super.key,
    required this.eventTitle,
  });

  final String eventTitle;

  @override
  State<EventBookingButton> createState() => _EventBookingButtonState();
}

class _EventBookingButtonState extends State<EventBookingButton> {
  bool _booking = false;

  Future<void> _book() async {
    if (!AuthService().isAuthenticated) {
      _showMessage('Please log in to book this event.');
      return;
    }

    setState(() => _booking = true);
    try {
      final events = await EventsService().fetchUpcomingEvents();
      EventModel? event;
      for (final candidate in events) {
        if (candidate.title.toLowerCase() == widget.eventTitle.toLowerCase()) {
          event = candidate;
          break;
        }
      }

      if (event == null) {
        throw Exception('This event is not currently scheduled.');
      }
      if (event.capacity > 0 && event.remainingSeats <= 0) {
        throw Exception('This event is full.');
      }

      await BookingService().createBooking(eventId: event.id, seats: 1);
      _showMessage('Your booking is confirmed.');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _booking = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _booking ? null : _book,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 245, 157, 74),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: _booking
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Book Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
