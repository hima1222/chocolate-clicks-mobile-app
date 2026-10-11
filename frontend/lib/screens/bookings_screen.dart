import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/booking_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingService _bookingService = BookingService();
  late Future<List<Booking>> _bookingsFuture;

  // Change this path if you name the image differently.
  static const String _backgroundImage = 'assets/images/workshops_collage2.jpg';

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _bookingService.getUserBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120101),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Bookings'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              _backgroundImage,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Dark chocolate gradient overlay for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF120101).withValues(alpha: 0.55),
                    const Color(0xFF120101).withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FutureBuilder<List<Booking>>(
              future: _bookingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD9A066)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Unable to load your bookings.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final bookings = snapshot.data ?? const <Booking>[];
                if (bookings.isEmpty) {
                  return _EmptyBookings(
                    onExploreEvents: () {
                      Navigator.pushNamed(context, '/events');
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: bookings.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _BookingCard(booking: bookings[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF6EC).withValues(alpha: 0.92),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFD9A066),
              child: Icon(
                Icons.confirmation_number_outlined,
                color: Color(0xFF5D3A2E),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.eventTitle,
                    style: const TextStyle(
                      color: Color(0xFF5D3A2E),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(booking.eventDate)} · ${booking.seats} seat${booking.seats == 1 ? '' : 's'}',
                    style: const TextStyle(color: Color(0xFF795548)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.status,
                    style: const TextStyle(
                      color: Color(0xFF8B5E34),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.onExploreEvents});

  final VoidCallback onExploreEvents;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        color: const Color(0xFFFFF6EC).withValues(alpha: 0.92),
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                color: Color(0xFF5D3A2E),
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'No bookings yet',
                style: TextStyle(
                  color: Color(0xFF5D3A2E),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onExploreEvents,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3A2E),
                ),
                child: const Text('Explore events'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}