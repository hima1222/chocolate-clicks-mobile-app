import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../widgets/app_image.dart';
import '../widgets/welcome_highlights.dart';

class EventParticipantsScreen extends StatefulWidget {
  const EventParticipantsScreen({super.key, required this.event});
  final EventModel event;
  @override
  State<EventParticipantsScreen> createState() =>
      _EventParticipantsScreenState();
}

class _EventParticipantsScreenState extends State<EventParticipantsScreen> {
  int _quantity = 1;
  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final limit = event.remainingSeats.clamp(0, 100).toInt();
    final fallback = event.title.toLowerCase().contains('mask')
        ? 'assets/images/c1.jpeg'
        : 'assets/images/bih1.jpg';
    final photo = event.cardImage.isNotEmpty
        ? event.cardImage
        : event.imageUrl.isNotEmpty
        ? event.imageUrl
        : fallback;
    final date = MaterialLocalizations.of(context).formatFullDate(event.date);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(event.date));
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: welcomeBackground,
        textTheme: Theme.of(
          context,
        ).textTheme.apply(bodyColor: welcomeCream, displayColor: welcomeCream),
      ),
      child: Scaffold(
        backgroundColor: welcomeBackground,
        appBar: AppBar(
          title: const Text('Your experience'),
          backgroundColor: welcomeBackground,
          foregroundColor: welcomeCream,
          surfaceTintColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 245,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppImage.asset(
                            photo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stack) =>
                                Image.asset(fallback, fit: BoxFit.cover),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xF2201710)],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MAKE A MEMORY',
                                  style: TextStyle(
                                    color: welcomeAccent,
                                    fontSize: 11,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    color: welcomeCream,
                                    fontFamily: 'serif',
                                    fontSize: 27,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detail(Icons.calendar_today_outlined, '$date • $time'),
                        if (event.location.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _detail(Icons.location_on_outlined, event.location),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Who’s joining you?',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 26,
                      color: welcomeCream,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose the number of persons for your session.',
                    style: TextStyle(color: welcomeMuted, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Persons',
                                  style: TextStyle(
                                    color: welcomeCream,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Rs. ${event.price.toStringAsFixed(2)} per person',
                                  style: const TextStyle(color: welcomeMuted),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _step(
                                  Icons.remove,
                                  'Remove person',
                                  _quantity > 1
                                      ? () => setState(() => _quantity--)
                                      : null,
                                ),
                                SizedBox(
                                  width: 48,
                                  child: Text(
                                    '$_quantity',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: welcomeCream,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _step(
                                  Icons.add,
                                  'Add person',
                                  _quantity < limit
                                      ? () => setState(() => _quantity++)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _detail(
                          Icons.confirmation_number_outlined,
                          '${event.remainingSeats} seats available',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'YOUR BOOKING',
                          style: TextStyle(
                            color: welcomeAccent,
                            letterSpacing: 1.8,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$_quantity ${_quantity == 1 ? 'person' : 'persons'} × Rs. ${event.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: welcomeMuted),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Color(0xFF615043)),
                        ),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: welcomeCream,
                                fontSize: 21,
                              ),
                            ),
                            Text(
                              'Rs. ${(event.price * _quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: welcomeAccent,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          onPressed: limit > 0
                              ? () => Navigator.pop(context, _quantity)
                              : null,
                          icon: const Icon(Icons.lock_outline, size: 18),
                          label: const Text('Continue to checkout'),
                          style: FilledButton.styleFrom(
                            backgroundColor: welcomeAccent,
                            foregroundColor: welcomeBackground,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Secure payment with PayHere',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: welcomeMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: welcomeSurface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: welcomeAccent.withValues(alpha: 0.2)),
    ),
    child: child,
  );
  Widget _detail(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: welcomeAccent, size: 19),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: welcomeMuted, height: 1.5),
        ),
      ),
    ],
  );
  Widget _step(IconData icon, String label, VoidCallback? action) =>
      IconButton.outlined(
        tooltip: label,
        onPressed: action,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          foregroundColor: welcomeAccent,
          disabledForegroundColor: welcomeMuted.withValues(alpha: 0.35),
          side: BorderSide(color: welcomeAccent.withValues(alpha: 0.3)),
        ),
      );
}
