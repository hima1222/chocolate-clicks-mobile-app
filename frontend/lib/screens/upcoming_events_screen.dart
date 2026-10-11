import 'package:flutter/material.dart';
import 'package:chocolate_clicks/models/event_model.dart';
import 'package:chocolate_clicks/services/api_client.dart';
import 'package:chocolate_clicks/services/auth_service.dart';
import 'package:chocolate_clicks/services/booking_service.dart';
import 'package:chocolate_clicks/services/events_service.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  static const _bg = Color(0xFF2A1C15);
  static const _card = Color(0xFF44372F);
  static const _cardBorder = Color(0xFF6B5B52);
  static const _caramel = Color(0xFFD9A066);
  static const _cream = Color(0xFFF7E6D8);
  static const _textSoft = Color(0xFFD8CCC4);

  // Background image + card transparency
  static const _bgImage = 'assets/images/cookies2.jpg';
  static const _bgImageOpacity = 0.30; // raise for a stronger image
  static const _cardOpacity = 0.85; // lower for more see-through cards

  Color get _cardFill => _card.withValues(alpha: _cardOpacity);

  final EventsService _eventsService = EventsService();
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();
  List<EventModel> _events = [];
  List<Booking> _bookings = [];
  bool _loading = true;
  String? _error;
  int _selectedTab = 0;
  String? _bookingEventId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final events = await _eventsService.fetchUpcomingEvents();
      var bookings = <Booking>[];
      if (_authService.isAuthenticated) {
        bookings = await _bookingService.getUserBookings();
      }
      if (!mounted) return;
      setState(() {
        _events = events;
        _bookings = bookings;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _errorMessage(error);
      });
    }
  }

  String _errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return error.toString().replaceFirst('Exception: ', '');
  }

  List<EventModel> get _filteredEvents {
    if (_selectedTab == 2) return const [];
    if (_selectedTab == 1) {
      final now = DateTime.now();
      final weekEnd = now.add(const Duration(days: 7));
      return _events
          .where(
            (event) =>
                !event.date.isBefore(now) && event.date.isBefore(weekEnd),
          )
          .toList();
    }
    return _events;
  }

  bool _isBooked(EventModel event) =>
      _bookings.any((booking) => booking.eventId == event.id);

  String _eventType(EventModel event) {
    final title = event.title.toLowerCase();
    if (title.contains('mask') || title.contains('workshop')) return 'Workshop';
    if (title.contains('tasting')) return 'Tasting';
    if (title.contains('bake')) return 'Baking';
    if (title.contains('picnic')) return 'Outdoor';
    return 'Experience';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background image (faded)
          Positioned.fill(
            child: Opacity(
              opacity: _bgImageOpacity,
              child: Image.asset(
                _bgImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          // Dark fade so cream text stays readable
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _bg.withValues(alpha: 0.45),
                    _bg.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
          // Page content
          SafeArea(
            child: RefreshIndicator(
              color: _caramel,
              backgroundColor: _card,
              onRefresh: () => _load(showLoading: false),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(child: _buildHeader()),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    sliver: SliverToBoxAdapter(child: _buildTabs()),
                  ),
                  if (_loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(color: _caramel),
                      ),
                    )
                  else if (_error != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildMessage(
                        'Unable to load events.\n$_error',
                        'Retry',
                        _load,
                      ),
                    )
                  else if (_selectedTab == 2)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildBookingsState(),
                    )
                  else if (_filteredEvents.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildMessage(
                        _selectedTab == 1
                            ? 'No events are scheduled this week.'
                            : 'No upcoming events found.',
                        null,
                        null,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.builder(
                        itemCount: _filteredEvents.length,
                        itemBuilder: (context, index) =>
                            _buildEventCard(_filteredEvents[index]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _cream),
        ),
        const SizedBox(width: 8),
        const Text(
          'Upcoming Events',
          style: TextStyle(
            color: _cream,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    const labels = ['All Events', 'This Week', 'My Bookings'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardFill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sweeten your day with Chocolate Clicks',
            style: TextStyle(
              color: _cream,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(labels.length, (index) {
              final selected = index == _selectedTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = index),
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: selected ? _caramel : _bg,
                    ),
                    child: Center(
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: selected ? _bg : _textSoft,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
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
    );
  }

  Widget _buildMessage(String message, String? action, VoidCallback? onAction) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _cardFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSoft),
            ),
            if (action != null) ...[
              const SizedBox(height: 14),
              TextButton(onPressed: onAction, child: Text(action)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsState() {
    if (!_authService.isAuthenticated) {
      return _buildMessage('Log in to see your bookings.', null, null);
    }
    if (_bookings.isEmpty) {
      return _buildMessage('You have no bookings yet.', null, null);
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      itemCount: _bookings.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.eventTitle,
                style: const TextStyle(
                  color: _cream,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(booking.eventDate),
                style: const TextStyle(color: _textSoft),
              ),
              const SizedBox(height: 4),
              Text(
                booking.status,
                style: const TextStyle(
                  color: _caramel,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    final full = event.remainingSeats <= 0;
    final booked = _isBooked(event);
    final booking = _bookingEventId == event.id;
    final buttonText = booked
        ? 'Booked'
        : full
        ? 'Fully booked'
        : 'Reserve';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardFill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 74,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: _caramel,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${event.date.day}',
                  style: const TextStyle(
                    color: _bg,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _monthAbbreviation(event.date.month),
                  style: const TextStyle(color: _bg, fontSize: 12),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _caramel.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _eventType(event),
                          style: const TextStyle(color: _caramel, fontSize: 12),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'LKR ${event.price.toStringAsFixed(0)}',
                        style: const TextStyle(color: _textSoft, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: _cream,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: const TextStyle(
                        color: _textSoft,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    event.location,
                    style: const TextStyle(color: _textSoft, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    full
                        ? 'Fully booked'
                        : '${event.remainingSeats} spot${event.remainingSeats == 1 ? '' : 's'} left',
                    style: TextStyle(
                      color: full ? _textSoft : _caramel,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: booking || full || booked
                          ? null
                          : () => _reserveEvent(event),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cream,
                        foregroundColor: _bg,
                        disabledBackgroundColor: _cream.withValues(alpha: 0.35),
                        disabledForegroundColor: _bg.withValues(alpha: 0.6),
                      ),
                      child: booking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(buttonText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reserveEvent(EventModel event) async {
    if (!_authService.isAuthenticated) {
      _showSnackBar('Please log in to reserve a spot.');
      return;
    }
    setState(() => _bookingEventId = event.id);
    try {
      await _bookingService.createBooking(eventId: event.id, seats: 1);
      if (!mounted) return;
      _showSnackBar(
        'Your booking is confirmed.',
        action: SnackBarAction(
          label: 'VIEW',
          textColor: _caramel,
          onPressed: () => Navigator.pushNamed(context, '/bookings'),
        ),
      );
      await _load(showLoading: false);
    } catch (error) {
      if (mounted) _showSnackBar(_errorMessage(error));
    } finally {
      if (mounted) setState(() => _bookingEventId = null);
    }
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), action: action));
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

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}