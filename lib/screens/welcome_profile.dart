import 'package:flutter/material.dart';

import '../widgets/primary_button.dart'; // Keep this - we'll use it for "Shop Here"
import 'cake_items_screen.dart';
import 'brownies_items_screen.dart';
import 'cookies_items_screen.dart';
import 'backing_goods.dart';
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

final List<Map<String, dynamic>> menuItems = [
  {'title': 'About Us', 'icon': Icons.info_outline},
  {'title': 'Contact Us', 'icon': Icons.contact_phone_outlined},
  {'title': 'FAQ', 'icon': Icons.help_outline},
  {'title': 'Terms & Conditions', 'icon': Icons.description_outlined},
  {'title': 'Privacy Policy', 'icon': Icons.privacy_tip_outlined},
];

class WelcomeProfileScreen extends StatelessWidget {
  const WelcomeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    void showMenuModal() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(radius: 28, backgroundColor: Colors.brown, child: Icon(Icons.person, color: Colors.white)),
                          SizedBox(width: 12),
                          Text('Subhani', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  ...menuItems.map((item) => ListTile(
                        leading: Icon(item['icon'] as IconData, color: Colors.brown[800]),
                        title: Text(item['title'] as String),
                        onTap: () {
                          Navigator.pop(context);
                          if (item['title'] == 'About Us') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const BakingGoodsScreen()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item['title']} tapped')));
                          }
                        },
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(

      extendBody: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/welcome_profile_bg.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha: 0.5)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
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
                            'Hello Subhani !', // Personalized based on your name (change if needed)
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '40/J, MC Road, Matale',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(

                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              // TODO: Navigate to notifications
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              // TODO: Navigate to cart
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),


                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(30),
                    ),

                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search Here...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: showMenuModal,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),


                  // Replaced custom InkWell with PrimaryButton for consistency & reusability
                  Center(
                    child: PrimaryButton(
                      text: 'Shop Here',
                      width: size.width * 0.7,
                      backgroundColor: Colors.white,

                      textColor: Colors.black87,
                      onPressed: () {
                        // Optional action (e.g., scroll to categories or show featured)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Start shopping!')),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),


                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final Widget? screen = category['screen'] as Widget?;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: screen != null
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => screen,
                                        ),
                                      );
                                    }
                                  : () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${category['name']} coming soon!',
                                          ),
                                        ),
                                      );
                                    },
                              child: Container(
                                width: size.width * 0.8,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: screen != null
                                      ? Colors.black.withValues(alpha: 0.6)
                                      : Colors.grey.withValues(
                                          alpha: 0.4,
                                        ), // Dimmed if not ready
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    category['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),


      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,

        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0: // Home - already here
              break;
            case 1: // Categories - stay on this screen
              break;
            case 2: // Events
              Navigator.pushNamed(context, '/events');
              break;
            case 3: // Messages - TODO: implement messages screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messages coming soon!')),
              );
              break;
            case 4: // Profile
              Navigator.pushNamed(context, '/profile');
              break;
          }
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


