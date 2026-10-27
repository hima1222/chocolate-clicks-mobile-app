import '../widgets/database_catalog.dart';
import '../widgets/welcome_highlights.dart';
import '../services/product_service.dart';
import 'package:chocolate_clicks/widgets/app_image.dart';
import 'dart:async';
import 'cake_type1.dart';
import 'brownies_type1.dart';
import 'cookies_type1.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/favorite_button.dart';
import 'package:chocolate_clicks/services/auth_service.dart';
import 'cake_items_screen.dart';
import 'brownies_items_screen.dart';
import 'cookies_items_screen.dart';
import 'categories_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';

final List<Map<String, dynamic>> categories = [
  {'name': 'Cake', 'screen': const CakeItemsScreen()},
  {'name': 'Brownies', 'screen': const BrowniesItemsScreen()},
  {'name': 'Cookies', 'screen': const CookiesItemsScreen()},
  {'name': 'Donuts', 'screen': null},
  {'name': 'Croissants', 'screen': null},
];

// Design tokens
const _bg = welcomeBackground;
const _surface = welcomeSurface;
const _cream = welcomeCream;
const _accent = welcomeAccent;
const _muted = welcomeMuted;

TextStyle _serif(double size, {Color color = _cream}) => GoogleFonts.fraunces(
  fontSize: size,
  color: color,
  fontWeight: FontWeight.w500,
  height: 1.15,
);
TextStyle _sans(
  double size, {
  Color color = _cream,
  FontWeight w = FontWeight.w400,
}) => GoogleFonts.inter(fontSize: size, color: color, fontWeight: w);

class WelcomeProfileScreen extends StatefulWidget {
  const WelcomeProfileScreen({super.key});

  @override
  State<WelcomeProfileScreen> createState() => _WelcomeProfileScreenState();
}

class _WelcomeProfileScreenState extends State<WelcomeProfileScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _animate = false;
  int _offerIndex = 0;
  Timer? _offerTimer;

  final List<Map<String, String>> _offeredEvents = const [
    {
      'title': 'Mask Painting Workshop',
      'image': 'assets/images/workshop_1.jpeg',
    },
    {'title': 'Bake It Happen', 'image': 'assets/images/bih1.jpg'},
    {
      'title': 'Mask Painting Workshop',
      'image': 'assets/images/workshop_2.jpeg',
    },
  ];

  List<Map<String, dynamic>> _catalog = [];
  Future<void> _loadCatalog() async {
    try {
      final products = await ProductService().fetchProducts();
      if (!mounted) return;
      setState(() => _catalog = products.map(productCardData).toList());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to load products.'),
          action: SnackBarAction(label: 'Retry', onPressed: _loadCatalog),
        ),
      );
    }
  }

  String get _userName {
    final user = _authService.currentUser;
    if (user == null) return 'Guest';
    if (user.firstName.trim().isEmpty) return 'Guest';
    return user.firstName;
  }

  List<Map<String, dynamic>> get _recommendedItems {
    final merged = _catalog
        .map(
          (item) => {
            ...item,
            'screen': switch (item['category']) {
              'Cakes' => CakeType1Screen(product: item),
              'Brownies' => BrowniesType1Screen(product: item),
              _ => CookiesType1Screen(product: item),
            },
          },
        )
        .toList();

    merged.sort((a, b) {
      final ratingCompare = (b['rating'] as double).compareTo(
        a['rating'] as double,
      );
      if (ratingCompare != 0) return ratingCompare;
      return (b['reviews'] as int).compareTo(a['reviews'] as int);
    });

    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return merged.take(6).toList();
    return merged
        .where(
          (item) =>
              '${item['title']} ${item['description']} ${item['category']}'
                  .toLowerCase()
                  .contains(query),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _animate = true);
    });
    _offerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _offerIndex = (_offerIndex + 1) % _offeredEvents.length);
    });
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ---------- Sections ----------

  Widget _sectionHeader(String title, {String? action, VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(title, style: _serif(22))),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              action,
              style: _sans(14, color: _accent, w: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHOCOLATE CLICKS',
                style: _sans(
                  12,
                  color: _accent,
                  w: FontWeight.w500,
                ).copyWith(letterSpacing: 1.6),
              ),
              const SizedBox(height: 6),
              Text('Hello $_userName', style: _serif(32)),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_outlined, color: _cream),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        IconButton(
          tooltip: 'Open profile',
          style: IconButton.styleFrom(
            backgroundColor: _surface,
            side: BorderSide(color: _cream.withValues(alpha: 0.3)),
          ),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          icon: Text(
            _userName.substring(0, 1).toUpperCase(),
            style: _sans(15, w: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: _sans(15),
        cursorColor: _accent,
        decoration: InputDecoration(
          hintText: 'Search cakes, brownies, cookies',
          hintStyle: _sans(15, color: _muted),
          prefixIcon: const Icon(Icons.search, color: _muted),
          suffixIcon: IconButton(
            tooltip: 'Clear search',
            icon: const Icon(Icons.clear, color: _muted),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildOfferEventsCard(BuildContext context) {
    final event = _offeredEvents[_offerIndex];
    return WelcomeEventBanner(
      image: event['image']!,
      title: event['title']!,
      index: _offerIndex,
      count: _offeredEvents.length,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EventsScreen()),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final Widget screen = product['screen'] as Widget;
    void open() =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    return SizedBox(
      width: 168,
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: open,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AppImage.asset(
                    product['image'] as String,
                    height: 124,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: _bg.withValues(alpha: 0.7),
                      shape: const CircleBorder(),
                      child: FavoriteButton(
                        name: product['title'] as String,
                        image: product['image'] as String,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _sans(14, w: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product['category']} · '
                      '${(product['rating'] as double).toStringAsFixed(1)} '
                      '(${product['reviews']})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _sans(12, color: _muted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs. ${(product['price'] as double).toStringAsFixed(0)}',
                          style: _sans(14, color: _accent, w: FontWeight.w600),
                        ),
                        IconButton.filled(
                          tooltip: 'View item',
                          onPressed: open,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF4A3627),
                            foregroundColor: _accent,
                            minimumSize: const Size(36, 36),
                          ),
                          icon: const Icon(Icons.arrow_forward, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final screen = category['screen'] as Widget?;
    return WelcomeCategoryPill(
      label: category['name'] as String,
      available: screen != null,
      onTap: () {
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${category['name']} coming soon!')),
          );
        }
      },
    );
  }

  Widget _buildOrderBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _muted.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Ready to place your order?', style: _sans(15))),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/categories'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF4A3627),
              foregroundColor: _cream,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shape: const StadiumBorder(),
            ),
            child: Text('Shop now', style: _sans(14, w: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cream.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: _accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Free delivery on orders above LKR 5,000',
              style: _sans(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final items = _recommendedItems;
    return SafeArea(
      bottom: false,
      child: AnimatedOpacity(
        opacity: _animate ? 1 : 0,
        duration: const Duration(milliseconds: 450),
        child: AnimatedSlide(
          offset: _animate ? Offset.zero : const Offset(0, 0.04),
          duration: const Duration(milliseconds: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 22),
                _buildSearch(),
                const SizedBox(height: 28),
                _sectionHeader(
                  'Featured events',
                  action: 'See all',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EventsScreen()),
                  ),
                ),
                const SizedBox(height: 4),
                _buildOfferEventsCard(context),
                const SizedBox(height: 28),
                _sectionHeader(
                  _searchQuery.trim().isEmpty
                      ? 'Recommended for you'
                      : 'Search results',
                ),
                const SizedBox(height: 14),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No items found. Try a different search.',
                      style: _sans(14, color: _muted),
                    ),
                  )
                else
                  SizedBox(
                    height: 262,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) =>
                          _buildProductCard(context, items[i]),
                    ),
                  ),
                const SizedBox(height: 28),
                _sectionHeader(
                  'Shop categories',
                  action: 'View all',
                  onTap: () => Navigator.pushNamed(context, '/categories'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: categories
                      .map((c) => _buildCategoryPill(context, c))
                      .toList(),
                ),
                const SizedBox(height: 24),
                _buildOrderBanner(context),
                const SizedBox(height: 12),
                _buildDeliveryNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Floating bottom nav ----------

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    return IconButton(
      tooltip: label,
      onPressed: () => setState(() => _currentIndex = index),
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? const Color(0xFF4A3627)
            : Colors.transparent,
        foregroundColor: selected ? _accent : _muted,
        minimumSize: const Size(48, 48),
      ),
      icon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildHomeContent(context),
      const CategoriesScreen(),
      const EventsScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: _bg,
      extendBody: true,
      body: pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: _cream.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_outlined, 'Home'),
              _navItem(1, Icons.grid_view, 'Categories'),
              _navItem(2, Icons.calendar_today_outlined, 'Events'),
              _navItem(3, Icons.shopping_bag_outlined, 'Cart'),
              _navItem(4, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
