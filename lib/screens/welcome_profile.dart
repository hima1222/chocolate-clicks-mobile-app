import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../screens/cake_items_screen.dart';
import '../../screens/brownies_items_screen.dart';
import '../../screens/cookies_items_screen.dart';
import '../../screens/backing_goods.dart';

final List<Map<String, dynamic>> categories = [
  {'name': 'Cake', 'screen': const CakeItemsScreen()},
  {'name': 'Brownies', 'screen': const BrowniesItemsScreen()},
  {'name': 'Cookies', 'screen': const CookiesItemsScreen()},
  {'name': 'Donuts', 'screen': null},
  {'name': 'Croissants', 'screen': null},
];

final List<Map<String, dynamic>> menuItems = [
  {'title': 'About Us', 'icon': Icons.info_outline},
  {'title': 'Contact Us', 'icon': Icons.contact_phone_outlined},
  {'title': 'FAQ', 'icon': Icons.help_outline},
  {'title': 'Terms & Conditions', 'icon': Icons.description_outlined},
  {'title': 'Privacy Policy', 'icon': Icons.privacy_tip_outlined},
];

class WelcomeProfileScreen extends StatelessWidget {
  WelcomeProfileScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/welcome_profile_bg.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top greeting + location + icons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hello Subhani !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '40/J, MC Road, Matale',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search Here...',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Shop Here button
        Center(
          child: PrimaryButton(
            text: 'Shop Here',
            width: size.width * 0.7,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Start shopping!')),
              );
            },
          ),
        ),
        const SizedBox(height: 30),

        // Categories list
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // disable inner scroll
          shrinkWrap: true, // important!
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
                            MaterialPageRoute(builder: (_) => screen),
                          );
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${category['name']} coming soon!')),
                          );
                        },
                  child: Container(
                    width: size.width * 0.8,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: screen != null
                          ? Colors.black.withOpacity(0.6)
                          : Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        category['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
      ],
    ),
  ),
)

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black.withOpacity(0.8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 0,
        onTap: (index) {
          final tabs = ['Home', 'Categories', 'Events', 'Messages', 'Profile'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${tabs[index]} tapped')),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.brown,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Subhani',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  'Baked Goods Lover',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...menuItems.map((item) {
            return ListTile(
              leading: Icon(item['icon'] as IconData, color: Colors.brown[800]),
              title: Text(item['title'] as String, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(40)),
              ),
              onTap: () {
                Navigator.pop(context);
                if (item['title'] == 'About Us') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BakingGoodsScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item['title']} tapped')),
                  );
                }
              },
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
