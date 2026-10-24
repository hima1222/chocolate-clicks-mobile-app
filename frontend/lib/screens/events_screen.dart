import 'package:flutter/material.dart';
import '../widgets/shop_page.dart';
import '../widgets/compact_shop_grid.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) Navigator.pushReplacementNamed(context, '/welcome_profile');
    },
    child: ShopPage(
      title: 'Events',
      subtitle: 'Discover the experiences hosted by Chocolate Clicks.',
      onBack: () => Navigator.pushReplacementNamed(context, '/welcome_profile'),
      children: [
        CompactShopGrid(
          children: [
            CompactShopCard(
              title: 'Bake It Happen',
              image: 'assets/images/bake-it-happen-bg.png',
              label: 'View event',
              onTap: () => Navigator.pushNamed(context, '/bake_it_happen'),
            ),
            CompactShopCard(
              title: 'Mask Painting Workshop',
              image: 'assets/images/mask_painting.jpg',
              label: 'View event',
              onTap: () =>
                  Navigator.pushNamed(context, '/mask_painting_workshop'),
            ),
          ],
        ),
      ],
    ),
  );
}
