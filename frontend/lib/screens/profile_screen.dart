import '../widgets/welcome_highlights.dart';
import 'about_us_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chocolate_clicks/services/auth_service.dart';
import 'package:chocolate_clicks/services/favorites_service.dart';
import 'package:chocolate_clicks/services/cart_service.dart';
import 'package:chocolate_clicks/services/events_service.dart';
import 'package:chocolate_clicks/services/payment_service.dart';
import 'package:chocolate_clicks/services/order_service.dart';
import 'package:chocolate_clicks/services/notification_service.dart';
import 'package:chocolate_clicks/services/image_upload_service.dart';
import 'package:chocolate_clicks/services/api_client.dart';
import 'package:chocolate_clicks/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Home page theme (dark chocolate)
  static const _bg = welcomeBackground;
  static const _card = welcomeSurface;
  static const _cardBorder = Color(0xFF594638);
  static const _caramel = welcomeAccent;
  static const _cream = welcomeCream;
  static const _textSoft = welcomeMuted;

  final AuthService _authService = AuthService();
  final FavoritesService _favoritesService = FavoritesService();
  final CartService _cartService = CartService();
  final EventsService _eventsService = EventsService();
  final PaymentService _paymentService = PaymentService();
  final OrderService _orderService = OrderService();
  final NotificationService _notificationService = NotificationService();
  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();

  int _favouritesCount = 0;
  int _cartCount = 0;
  int _ordersCount = 0;
  int _eventsCount = 0;
  bool _loading = true;
  bool _uploadingProfileImage = false;

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

  Future<void> _uploadProfileImage() async {
    if (_uploadingProfileImage) return;

    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;

    setState(() => _uploadingProfileImage = true);
    try {
      final bytes = await image.readAsBytes();
      final mimeType = image.mimeType ?? _mimeTypeFor(image.name);
      final upload = await _imageUploadService.upload(
        bytes: bytes,
        filename: image.name,
        mimeType: mimeType,
      );
      final imageUrl = upload['imageUrl']?.toString();
      if (imageUrl == null || imageUrl.isEmpty) {
        throw ApiException(message: 'The uploaded image URL was missing');
      }

      final response = await _authService.updateProfile(
        profileImageUrl: imageUrl,
      );
      if (!mounted) return;
      if (!response.success) {
        throw AuthException(message: response.message);
      }
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
    } catch (error) {
      if (!mounted) return;
      final message = error is AuthException
          ? error.message
          : error is ApiException
          ? error.message
          : 'Unable to update your profile photo. Please try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _uploadingProfileImage = false);
    }
  }

  String _mimeTypeFor(String filename) {
    switch (filename.toLowerCase().split('.').last) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'png':
        return 'image/png';
      default:
        return 'image/jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final fullName = user?.fullName ?? 'Guest User';
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    '/welcome_profile',
                  ),
                  icon: const Icon(Icons.arrow_back, color: _cream),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Your account',
                    style: TextStyle(
                      color: _cream,
                      fontSize: 26,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: _card,
                      child: user?.profileImageUrl?.isNotEmpty == true
                          ? ClipOval(
                              child: Image.network(
                                user!.profileImageUrl!,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _profileInitials(fullName),
                              ),
                            )
                          : _profileInitials(fullName),
                    ),
                    Positioned(
                      right: -8,
                      bottom: -8,
                      child: IconButton(
                        tooltip: 'Update profile photo',
                        onPressed: _uploadingProfileImage
                            ? null
                            : _uploadProfileImage,
                        style: IconButton.styleFrom(
                          backgroundColor: _card,
                          side: const BorderSide(color: _cardBorder),
                        ),
                        icon: _uploadingProfileImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _caramel,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: _caramel,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: _cream,
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (user?.phone.isNotEmpty == true)
                        Text(
                          user!.phone,
                          style: const TextStyle(
                            color: _textSoft,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        user?.createdAt == null
                            ? 'Your Chocolate Clicks account'
                            : 'Member since ${_memberSinceYear(user!.createdAt)}',
                        style: const TextStyle(color: _caramel, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_outline, color: _caramel),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Make it yours. Keep your name, photo, and contact details up to date.',
                      style: TextStyle(color: _textSoft, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionLabel('ACCOUNT'),
            _menuGroup([
              _buildMenuItem(
                icon: Icons.person_outline,
                label: 'Personal details',
                subtitle: 'Name, photo, and contact details',
                onTap: () async {
                  await Navigator.pushNamed(context, '/edit_profile');
                  if (mounted) setState(() {});
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.payment_outlined,
                label: 'Payment methods',
                subtitle: 'Manage your payment information',
                onTap: () => Navigator.pushNamed(context, '/payment_info'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                subtitle: 'Updates about your orders',
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
            ]),
            const SizedBox(height: 24),
            _sectionLabel('YOUR SWEET COLLECTION'),
            _menuGroup([
              _buildMenuItem(
                icon: Icons.receipt_long_outlined,
                label: 'Order Details',
                subtitle: _loading
                    ? 'Loading your orders...'
                    : 'Order history and progress',
                badgeCount: _ordersCount,
                onTap: () async {
                  await Navigator.pushNamed(context, '/orders');
                  if (mounted) _loadCounts();
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.confirmation_number_outlined,
                label: 'My Bookings',
                subtitle: 'Your reserved experiences',
                onTap: () => Navigator.pushNamed(context, '/bookings'),
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
                icon: Icons.shopping_bag_outlined,
                label: 'Cart',
                subtitle: '$_cartCount items ready',
                badgeCount: _cartCount,
                onTap: () => Navigator.pushNamed(context, '/cart'),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.calendar_today_outlined,
                label: 'Upcoming Events',
                subtitle: '$_eventsCount scheduled experiences',
                onTap: () => Navigator.pushNamed(context, '/upcoming_events'),
              ),
            ]),
            const SizedBox(height: 24),
            _sectionLabel('GET TO KNOW US'),
            _menuGroup([
              _buildMenuItem(
                icon: Icons.storefront_outlined,
                label: 'About us',
                subtitle: 'Our cafes, art studio, and visiting details',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                ),
              ),
            ]),
            const SizedBox(height: 24),
            TextButton.icon(
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
              label: const Text('Sign out'),
              style: TextButton.styleFrom(
                foregroundColor: _caramel,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chocolate Clicks · Colombo',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textSoft, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Text(
      label,
      style: const TextStyle(
        color: _textSoft,
        fontSize: 10,
        letterSpacing: 1.5,
      ),
    ),
  );

  Widget _menuGroup(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _cardBorder.withValues(alpha: 0.5)),
    ),
    child: Column(children: children),
  );

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
          color: const Color(0xFF49382A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: _caramel, size: 20),
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
      color: _cardBorder.withValues(alpha: 0.5),
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

  Widget _profileInitials(String fullName) {
    return Center(
      child: Text(
        _getInitials(fullName),
        style: const TextStyle(
          color: _cream,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _memberSinceYear(DateTime? date) {
    if (date == null) return '2023';
    return date.year.toString();
  }
}
