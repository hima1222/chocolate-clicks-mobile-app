import 'package:flutter/material.dart';
import 'package:chocolate_clicks/models/event_model.dart';
import 'package:chocolate_clicks/services/auth_service.dart';
import 'package:chocolate_clicks/services/booking_service.dart';
import 'package:chocolate_clicks/services/events_service.dart';
import 'package:chocolate_clicks/services/payment_service.dart';

class EventBookingButton extends StatefulWidget {
  const EventBookingButton({
    super.key,
    required this.eventTitle,
    this.eventId,
    this.enabled = true,
  });
  final String eventTitle;
  final String? eventId;
  final bool enabled;
  @override
  State<EventBookingButton> createState() => _EventBookingButtonState();
}

class _EventBookingButtonState extends State<EventBookingButton> {
  bool _booking = false;
  bool _paid = false;
  String? _orderId;

  Future<Map<String, String>?> _billing() async {
    final address = TextEditingController();
    final city = TextEditingController();
    final country = TextEditingController(text: 'Sri Lanka');
    final form = GlobalKey<FormState>();
    try {
      return await showDialog<Map<String, String>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Billing details'),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final field in [
                    ('Address', address),
                    ('City', city),
                    ('Country', country),
                  ])
                    TextFormField(
                      controller: field.$2,
                      maxLength: 200,
                      decoration: InputDecoration(labelText: field.$1),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (form.currentState!.validate()) {
                  Navigator.pop(context, {
                    'address': address.text.trim(),
                    'city': city.text.trim(),
                    'country': country.text.trim(),
                  });
                }
              },
              child: const Text('Continue to payment'),
            ),
          ],
        ),
      );
    } finally {
      // Wait until the dialog's reverse animation has disposed its text fields.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      address.dispose();
      city.dispose();
      country.dispose();
    }
  }

  void _displayOrder(EventPaymentOrder order, {String? checkoutMessage}) {
    if (order.status == 'paid') {
      if (mounted) setState(() => _paid = true);
      _showMessage('Payment verified. Your booking is confirmed.');
    } else if (order.status == 'pending') {
      _showMessage(
        '${checkoutMessage == null ? '' : '$checkoutMessage '}Payment processing. Check status again shortly.',
      );
    } else {
      _showMessage(
        checkoutMessage ?? 'Payment ${order.status}. You can retry checkout.',
      );
    }
  }

  Future<void> _book({bool retry = false}) async {
    if (!widget.enabled && _orderId == null) return;
    if (!AuthService().isAuthenticated) {
      _showMessage('Please log in to book this event.');
      return;
    }
    setState(() => _booking = true);
    try {
      if (_orderId != null) {
        final order = await PaymentService().pollOrder(_orderId!);
        if (!retry || order.status == 'paid') {
          _displayOrder(order);
          return;
        }
        if (!mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Retry checkout?'),
            content: const Text(
              'If your account was charged, wait for payment verification. Retrying a payment may charge you again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Wait'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Retry checkout'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
      final events = await EventsService().fetchUpcomingEvents();
      EventModel? event;
      for (final candidate in events) {
        if (!candidate.date.isAfter(DateTime.now())) continue;
        if (widget.eventId != null
            ? candidate.id == widget.eventId
            : candidate.title.toLowerCase() ==
                  widget.eventTitle.toLowerCase()) {
          event = candidate;
          break;
        }
      }
      if (event == null) {
        throw Exception('This event is not currently scheduled.');
      }
      if (event.capacity > 0 && event.remainingSeats <= 0) {
        throw Exception('This session is fully booked.');
      }
      if (event.price <= 0) {
        await BookingService().createBooking(eventId: event.id, seats: 1);
        if (mounted) setState(() => _paid = true);
        _showMessage('Your booking is confirmed.');
        return;
      }
      if (!mounted) return;
      final billing = await _billing();
      if (billing == null || !mounted) return;
      final result = await PaymentService().checkoutEvent(
        eventId: event.id,
        quantity: 1,
        retryExisting: retry,
        billing: billing,
        onOrderCreated: (id) {
          if (mounted) setState(() => _orderId = id);
        },
        onProcessing: () => _showMessage('Payment processing...'),
      );
      _displayOrder(result.order, checkoutMessage: result.message);
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ElevatedButton(
        onPressed: _booking || _paid || (!widget.enabled && _orderId == null)
            ? null
            : () => _book(),
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
            : Text(
                _paid
                    ? 'Booking confirmed'
                    : _orderId == null
                    ? 'Book Now'
                    : 'Check payment status',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
      ),
      if (_orderId != null && !_paid)
        TextButton(
          onPressed: _booking ? null : () => _book(retry: true),
          child: const Text('Retry checkout'),
        ),
    ],
  );
}
