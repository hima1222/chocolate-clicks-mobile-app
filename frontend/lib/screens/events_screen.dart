import 'package:flutter/material.dart';
import '../widgets/shop_page.dart';
import '../widgets/compact_shop_grid.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  static const _events = [
    // Future feature: restore this event when implemented.
    // (
    //   title: 'Baking Goods',
    //   image: 'assets/images/cake7.jpg',
    //   route: '/baking_goods',
    // ),
    (
      title: 'Bake It Happen',
      image: 'assets/images/bake-it-happen-bg.png',
      route: '/bake_it_happen',
    ),
    // Future feature: restore this event when implemented.
    // (
    //   title: 'Cake Dates',
    //   image: 'assets/images/cake8.jpg',
    //   route: '/cake_dates',
    // ),
    (
      title: 'Mask Painting Workshop',
      image: 'assets/images/mask_painting.jpg',
      route: '/mask_painting_workshop',
    ),
    // Future features: restore these events when implemented.
    // (
    //   title: 'Tasting LUXE',
    //   image: 'assets/images/cake7.jpg',
    //   route: '/tasting_luxe',
    // ),
    // (
    //   title: 'Summer Cake Picnics',
    //   image: 'assets/images/cake3.jpg',
    //   route: '/summer_cake_picnics',
    // ),
  ];

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) {
        Navigator.pushReplacementNamed(context, '/welcome_profile');
      }
    },
    child: ShopPage(
      title: 'Events',
      subtitle: 'Explore experiences at Chocolate Clicks',
      onBack: () => Navigator.pushReplacementNamed(context, '/welcome_profile'),
      children: [
        CompactShopGrid(
          children: [
            for (final event in _events)
              CompactShopCard(
                title: event.title,
                image: event.image,
                label: 'View event',
                onTap: () => Navigator.pushNamed(context, event.route),
              ),
          ],
        ),
      ],
    ),
  );
}
