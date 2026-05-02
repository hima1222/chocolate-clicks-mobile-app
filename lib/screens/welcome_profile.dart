import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/auth_service.dart';
import '../../screens/cake_items_screen.dart';
import '../../screens/brownies_items_screen.dart';
import '../../screens/cookies_items_screen.dart';
import '../../screens/categories_screen.dart';
import '../../screens/events_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/messages_screen.dart';
// Add these later when you create the screens
// import '../../screens/donuts_items_screen.dart';
// import '../../screens/croissants_items_screen.dart';

final List<Map<String, dynamic>> categories = [
  {'name': 'Cake', 'screen': const CakeItemsScreen()},
  {'name': 'Brownies', 'screen': const BrowniesItemsScreen()},
  {'name': 'Cookies', 'screen': const CookiesItemsScreen()},

  {'name': 'Donuts', 'screen': null}, // Replace with actual screen when ready
  {
    'name': 'Croissants',
    'screen': null,
  }, // Replace with actual screen when ready
];

class WelcomeProfileScreen extends StatefulWidget {
  const WelcomeProfileScreen({super.key});

  @override
  State<WelcomeProfileScreen> createState() => _WelcomeProfileScreenState();
}

class _WelcomeProfileScreenState extends State<WelcomeProfileScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  bool _animate = false;
  int _offerIndex = 0;
  Timer? _offerTimer;

  final List<Map<String, String>> _offeredEvents = const [
    {
      'title': 'Mask Painting Workshops',
      'image': 'assets/images/workshops_collage1.jpg',
    },
    {'title': 'Tasting LUXE', 'image': 'assets/images/cake7.jpg'},
    {'title': 'Bake It Happen', 'image': 'assets/images/event_background.png'},
    {'title': 'Summer Cake Picnics', 'image': 'assets/images/cake3.jpg'},
    {'title': 'Cake Dates', 'image': 'assets/images/cake8.jpg'},
  ];

  String get _userName {
    final user = _authService.currentUser;
    if (user == null) return 'Guest';
    if (user.firstName.trim().isEmpty) return 'Guest';
    return user.firstName;
  }

  List<Map<String, dynamic>> get _recommendedItems {
    final merged = <Map<String, dynamic>>[
      ...CakeItemsScreen.cakeProducts.map(
        (item) => {...item, 'screen': const CakeItemsScreen()},
      ),
      ...BrowniesItemsScreen.brownieProducts.map(
        (item) => {...item, 'screen': const BrowniesItemsScreen()},
      ),
      ...CookiesItemsScreen.cookieProducts.map(
        (item) => {...item, 'screen': const CookiesItemsScreen()},
      ),
    ];

    merged.sort((a, b) {
      final ratingCompare =
          (b['rating'] as double).compareTo(a['rating'] as double);
      if (ratingCompare != 0) return ratingCompare;
      return (b['reviews'] as int).compareTo(a['reviews'] as int);
    });

    return merged.take(6).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _animate = true;
      });
    });
    _offerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _offerIndex = (_offerIndex + 1) % _offeredEvents.length;
      });
    });
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    super.dispose();
  }

  Widget _buildHomeContent(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/welcome_profile_bg.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1410), Color(0xFF3A2A1F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -20,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        SafeArea(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chocolate Clicks',
                              style: TextStyle(
                                color: Color(0xFFF6E6D7),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                height: 1.2,
                                fontFamily: 'serif',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hello $_userName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _userName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/notifications');
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/cart');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search cakes, brownies, cookies...',
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          suffixIcon: Icon(Icons.tune, color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Chocolate Clicks will offer you...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOfferEventsCard(context),
                    const SizedBox(height: 8),
                    Text(
                      'Now showing: ${_offeredEvents[_offerIndex]['title']}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Recommended For You...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Today',
                          style: TextStyle(
                            color: Color(0xFFF6E6D7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recommendedItems.length,
                        separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final product = _recommendedItems[index];
                          return _buildProductCard(context, product);
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Shop Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/categories',
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFFF6E6D7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: categories
                          .map((category) => _buildCategoryPill(
                                context,
                                category,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Ready to place your order?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/categories');
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFFF6E6D7),
                                foregroundColor: const Color(0xFF1A1410),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Shop Now',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: Color(0xFFF6E6D7),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Free delivery for orders above LKR 5,000',
                              style: TextStyle(color: Colors.white),
                            ),
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
      ],
    );
  }

  Widget _buildOfferEventsCard(BuildContext context) {
    final event = _offeredEvents[_offerIndex];
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EventsScreen()),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(event['image']!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.65),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Our Featured Events...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.event_available,
                    size: 16,
                    color: Color(0xFFF6E6D7),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.35),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        event['title']!,
                        key: ValueKey<String>(event['title']!),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(_offeredEvents.length, (index) {
                  final active = index == _offerIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: active ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFF6E6D7)
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap to open all events',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final Widget screen = product['screen'] as Widget;
    return Container(
      width: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.asset(
              product['image'] as String,
              height: 88,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Text(
              product['title'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.15,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${(product['rating'] as double).toStringAsFixed(1)} (${product['reviews']}) ratings',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Text(
              'Rs. ${(product['price'] as double).toStringAsFixed(0)}',
              style: const TextStyle(
                color: Color(0xFFF6E6D7),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => screen),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6E6D7),
                  foregroundColor: const Color(0xFF1A1410),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'View Item',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final Widget? screen = category['screen'] as Widget?;
    final bool enabled = screen != null;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: enabled
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => screen),
              );
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${category['name']} coming soon!'),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: enabled
                ? Colors.white.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          category['name'],
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildHomeContent(context),
      const CategoriesScreen(),
      const EventsScreen(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}


