import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  static const _events = [
    (
      title: 'Baking Goods',
      image: 'assets/images/cake7.jpg',
      route: '/baking_goods',
    ),
    (
      title: 'Bake It Happen',
      image: 'assets/images/event_background.png',
      route: '/bake_it_happen',
    ),
    (
      title: 'Cake Dates',
      image: 'assets/images/cake8.jpg',
      route: '/cake_dates',
    ),
    (
      title: 'Mask Painting Workshop',
      image: 'assets/images/workshops_collage1.jpg',
      route: '/mask_painting_workshop',
    ),
    (
      title: 'Tasting LUXE',
      image: 'assets/images/cake7.jpg',
      route: '/tasting_luxe',
    ),
    (
      title: 'Summer Cake Picnics',
      image: 'assets/images/cake3.jpg',
      route: '/summer_cake_picnics',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120101),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Explore experiences at Chocolate Clicks',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 22),
            for (final event in _events)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: const Color(0xFF1F0A0A),
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, event.route),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          event.image,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
