import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/auth_service.dart';
import 'package:chocolate_clicks/services/favorites_service.dart';
import 'package:chocolate_clicks/services/cart_service.dart';
import 'package:chocolate_clicks/services/events_service.dart';
import 'package:chocolate_clicks/services/payment_service.dart';
import 'package:chocolate_clicks/services/order_service.dart';
import 'package:chocolate_clicks/services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Home page theme (dark chocolate)
  static const _bg = Color(0xFF2A1C15);
  static const _card = Color(0xFF44372F);
  static const _cardBorder = Color(0xFF6B5B52);
  static const _caramel = Color(0xFFD9A066);
  static const _cream = Color(0xFFF7E6D8);
  static const _textSoft = Color(0xFFD8CCC4);

  final AuthService _authService = AuthService();
  final FavoritesService _favoritesService = FavoritesService();
  final CartService _cartService = CartService();
  final EventsService _eventsService = EventsService();
  final PaymentService _paymentService = PaymentService();
  final OrderService _orderService = OrderService();
  final NotificationService _notificationService = NotificationService();

  int _favouritesCount = 0;
  int _cartCount = 0;
  int _ordersCount = 0;
  int _eventsCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _favouritesCount = _favoritesService.count;
    _favoritesService.addListener(_updateFavoritesCount);
    _loadCounts();
  }

  void _updateFavoritesCount() {
    if (!mounted) return;
    setState(() => _favouritesCount = _favoritesService.count);
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_updateFavoritesCount);
    super.dispose();
  }

  Future<void> _loadCounts() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final results = await Future.wait([
        _favoritesService.fetchFavorites(),
        _cartService.fetchCartItems(),
        _orderService.fetchUserOrders(user.id),
        _eventsService.fetchUpcomingEvents(),
      ]);

      if (!mounted) return;
      setState(() {
        _favouritesCount = (results[0] as List).length;
        _cartCount = (results[1] as List).length;
        _ordersCount = (results[2] as List).length;
        _eventsCount = (results[3] as List).length;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final fullName = user?.fullName ?? 'Guest User';
    final subtitle = 'Sweet member since ${_memberSinceYear(user?.createdAt)}';

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Soft decorative circle (like the home page header)
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/welcome_profile',
                        ),
                        icon: const Icon(Icons.arrow_back, color: _cream),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: _cream,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFE8B77C), Color(0xFFB9783A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: _bg,
                            child: Text(
                              _getInitials(fullName),
                              style: const TextStyle(
                                color: _cream,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          fullName,
                          style: const TextStyle(
                            color: _cream,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: _textSoft,
                            fontSize: 13,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _loading
                            ? const SizedBox(
                                height: 68,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: _caramel,
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  _buildStatItem('Orders', _ordersCount),
                                  const SizedBox(width: 10),
                                  _buildStatItem('Events', _eventsCount),
                                  const SizedBox(width: 10),
                                  _buildStatItem('Points', 240),
                                ],
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu card
                  Container(
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.edit,
                          label: 'Edit Profile',
                          subtitle: 'Name, photo, preferences',
                          onTap: () =>
                              Navigator.pushNamed(context, '/edit_profile'),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.confirmation_number_outlined,
                          label: 'My Bookings',
                          subtitle: 'View your reserved experiences',
                          onTap: () =>
                              Navigator.pushNamed(context, '/bookings'),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.favorite_border,
                          label: 'Favourites',
                          subtitle: 'Your saved treats',
                          badgeCount: _favouritesCount,
                          onTap: () async {
                            await Navigator.pushNamed(context, '/favourites');
                            if (mounted) _loadCounts();
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.shopping_cart_outlined,
                          label: 'Cart',
                          subtitle: '$_cartCount items ready',
                          badgeCount: _cartCount,
                          onTap: () => Navigator.pushNamed(context, '/cart'),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.calendar_today,
                          label: 'Upcoming Events',
                          subtitle: 'See your next experiences',
                          onTap: () => Navigator.pushNamed(
                              context, '/upcoming_events'),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.payment,
                          label: 'Payment Info',
                          subtitle: 'Visa ending 4242',
                          onTap: () =>
                              Navigator.pushNamed(context, '/payment_info'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Log out button (cream, like "View Item" / "Shop Now")
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _authService.logout();
                        _favoritesService.clear();
                        _cartService.clear();
                        _eventsService.clear();
                        _paymentService.clear();
                        _orderService.clear();
                        _notificationService.clear();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, '/landing');
                      },
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Log out',
                        style: TextStyle(fontSize: 16, letterSpacing: 0.4),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cream,
                        foregroundColor: _bg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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

  Widget _buildStatItem(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder.withOpacity(0.6)),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                color: _caramel,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSoft, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _caramel,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: _bg, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(color: _cream, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: _textSoft, fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _caramel,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: _bg,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          const Icon(Icons.chevron_right, color: _textSoft, size: 22),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: _cardBorder.withOpacity(0.5),
      height: 1,
      thickness: 1,
      indent: 18,
      endIndent: 18,
    );
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return 'G';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _memberSinceYear(DateTime? date) {
    if (date == null) return '2023';
    return date.year.toString();
  }
}