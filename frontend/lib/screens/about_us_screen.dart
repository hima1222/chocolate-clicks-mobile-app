import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/welcome_highlights.dart';
import '../widgets/app_image.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: welcomeBackground,
    appBar: AppBar(
      title: const Text('About us'),
      backgroundColor: welcomeBackground,
      foregroundColor: welcomeCream,
      surfaceTintColor: Colors.transparent,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        const Text(
          'CHOCOLATE CLICKS',
          style: TextStyle(
            color: welcomeAccent,
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Sweet moments. Creative memories.',
          style: TextStyle(
            color: welcomeCream,
            fontFamily: 'serif',
            fontSize: 28,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Discover cakes, brownies, cookies, and shared experiences at Chocolate Clicks. From a favourite treat to a hands-on creative session, there is a little something to enjoy together.',
          style: TextStyle(color: welcomeMuted, fontSize: 15, height: 1.7),
        ),
        const SizedBox(height: 24),
        _place(
          Icons.storefront_outlined,
          'Colombo cafe',
          'ORDERING BRANCH',
          'assets/images/cafe_background.jpeg',
          [
            const Text(
              'No. 8, Stratford Avenue, Havelock Town, Colombo 06, Sri Lanka',
              style: TextStyle(color: welcomeCream, height: 1.6),
            ),
            const SizedBox(height: 10),
            const Text(
              'Orders through this app are for our Colombo branch.',
              style: TextStyle(color: welcomeMuted, height: 1.5),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _place(
          Icons.palette_outlined,
          'Art Studio by Chocolate Clicks',
          'CREATE WITH US',
          'assets/images/c1.jpeg',
          [
            const Text(
              'No. 17, Stratford Avenue, Colombo 06, Sri Lanka',
              style: TextStyle(color: welcomeCream, height: 1.6),
            ),
            const SizedBox(height: 12),
            const Text(
              'Craft and mask-painting sessions',
              style: TextStyle(color: welcomeMuted, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Open daily · 10:30 AM – 6:00 PM',
              style: TextStyle(color: welcomeAccent, height: 1.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  '+94 71 996 9798',
                  style: TextStyle(color: welcomeCream),
                ),
                IconButton(
                  tooltip: 'Copy studio phone number',
                  icon: const Icon(
                    Icons.copy_outlined,
                    color: welcomeAccent,
                    size: 18,
                  ),
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: '+94 71 996 9798'),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Studio phone number copied'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _place(
          Icons.public,
          'Gothenburg branch',
          'SWEDEN',
          'assets/images/home3.jpg',
          [
            const Text(
              'A taste of Chocolate Clicks',
              style: TextStyle(color: welcomeAccent, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gothenburg, Sweden',
              style: TextStyle(color: welcomeCream, height: 1.6),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _place(
    IconData icon,
    String title,
    String eyebrow,
    String image,
    List<Widget> children,
  ) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: welcomeSurface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: welcomeMuted.withValues(alpha: 0.16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppImage.asset(
          image,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: welcomeAccent, size: 26),
              const SizedBox(height: 14),
              Text(
                eyebrow,
                style: const TextStyle(
                  color: welcomeMuted,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: welcomeCream,
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ],
    ),
  );
}
