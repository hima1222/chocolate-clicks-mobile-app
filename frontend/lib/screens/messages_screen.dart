import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/auth_service.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  List<Map<String, String>> _personalMessages(String userName) {
    return [
      {
        'title': 'Hi $userName, your favorites are back',
        'message': 'Our signature Dark Fudge Brownie is available again. Tap categories to order quickly.',
        'time': '1h ago',
      },
      {
        'title': 'Order support reminder',
        'message': 'Need help with customization? Our Chocolate Clicks team can assist you in minutes.',
        'time': 'Today',
      },
      {
        'title': 'Taste profile recommendation',
        'message': 'Based on your recent picks, try the Salted Caramel Cake this week.',
        'time': 'Yesterday',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final userName = (user?.firstName.trim().isNotEmpty ?? false)
        ? user!.firstName
        : 'Guest';
    final messages = _personalMessages(userName);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/cafe_background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xD914100D), Color(0xF0291C14)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFFF6E6D7),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Messages',
                          style: TextStyle(
                            color: Color(0xFFF6E6D7),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                    itemCount: messages.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = messages[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFFF6E6D7),
                              child: Text(
                                'C',
                                style: TextStyle(
                                  color: Colors.brown.shade900,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['title']!,
                                          style: const TextStyle(
                                            color: Color(0xFFF6E6D7),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item['time']!,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.78),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['message']!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
