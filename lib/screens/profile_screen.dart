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
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final user = _authService.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final results = await Future.wait([
        _favoritesService.fetchFavorites(),
        _cartService.fetchCartItems(),
        _orderService.fetchUserOrders(user.id),
        _eventsService.fetchUpcomingEvents(),
      ]);

      setState(() {
        _favouritesCount = (results[0] as List).length;
        _cartCount = (results[1] as List).length;
        _ordersCount = (results[2] as List).length;
        _eventsCount = (results[3] as List).length;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final fullName = user?.fullName ?? 'Guest User';
    final subtitle = 'Sweet member since ${_memberSinceYear(user?.createdAt)}';
    return Scaffold(
      backgroundColor: const Color(0xFF120101),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3C090A), Color(0xFF120101)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: Colors.red.shade900.withOpacity(0.7)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF5350), Color(0xFFB71C1C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFF3C090A),
                        child: Text(
                          _getInitials(fullName),
                          style: const TextStyle(
                            color: Colors.white,
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
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
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
                                color: Colors.white,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.edit,
                      label: 'Edit Profile',
                      subtitle: 'Name, photo, preferences',
                      onTap: () => Navigator.pushNamed(context, '/edit_profile'),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.favorite_border,
                      label: 'Favourites',
                      subtitle: 'Your saved treats',
                      badgeCount: _favouritesCount,
                      onTap: () => Navigator.pushNamed(context, '/favourites'),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.shopping_cart_outlined,
                      label: 'Cart',
                      subtitle: '$_cartCount items ready',
                      badgeCount: _cartCount,
                      onTap: () => Navigator.pushNamed(context, '/cart'),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Upcoming Events',
                      subtitle: 'See your next experiences',
                      onTap: () => Navigator.pushNamed(context, '/upcoming_events'),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.payment,
                      label: 'Payment Info',
                      subtitle: 'Visa ending 4242',
                      onTap: () => Navigator.pushNamed(context, '/payment_info'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await _authService.logout();
                    _favoritesService.clear();
                    _cartService.clear();
                    _eventsService.clear();
                    _paymentService.clear();
                    _orderService.clear();
                    _notificationService.clear();
                    Navigator.pushReplacementNamed(context, '/landing');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Log out',
                    style: TextStyle(fontSize: 16, letterSpacing: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
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
          color: const Color(0xFF451212),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white12, height: 1, thickness: 1);
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return 'G';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _memberSinceYear(DateTime? date) {
    if (date == null) return '2023';
    return date.year.toString();
  }
}
