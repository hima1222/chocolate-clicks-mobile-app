import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/auth_service.dart';
import 'package:chocolate_clicks/services/favorites_service.dart';
import 'package:chocolate_clicks/services/cart_service.dart';
import 'package:chocolate_clicks/services/events_service.dart';
import 'package:chocolate_clicks/services/payment_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final favoritesService = FavoritesService();
    final cartService = CartService();
    final eventsService = EventsService();
    final paymentService = PaymentService();
    return Scaffold(
      body: Stack(
        children: [
          // background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/profile_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // profile picture and name loaded from service
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        authService.currentUser?.profileImageUrl != null
                        ? NetworkImage(
                            authService.currentUser!.profileImageUrl!,
                          )
                        : null,
                    child: authService.currentUser?.profileImageUrl == null
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authService.currentUser?.fullName ?? 'Guest User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // menu card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.edit,
                          label: 'Edit Profile',
                          onTap: () =>
                              Navigator.pushNamed(context, '/edit_profile'),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          icon: Icons.favorite_border,
                          label: 'Favourites',
                          onTap: () =>
                              Navigator.pushNamed(context, '/favourites'),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          icon: Icons.shopping_cart_outlined,
                          label: 'Cart',
                          onTap: () => Navigator.pushNamed(context, '/cart'),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          icon: Icons.calendar_today,
                          label: 'Upcoming Events',
                          onTap: () =>
                              Navigator.pushNamed(context, '/upcoming_events'),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          icon: Icons.payment,
                          label: 'Payment Info',
                          onTap: () =>
                              Navigator.pushNamed(context, '/payment_info'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // log out through AuthService
                        await authService.logout();
                        // clear auxiliary services
                        favoritesService.clear();
                        cartService.clear();
                        eventsService.clear();
                        paymentService.clear();
                        Navigator.pushReplacementNamed(context, '/landing');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 202, 38, 38),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16),
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown[700]),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.grey);
  }
}
