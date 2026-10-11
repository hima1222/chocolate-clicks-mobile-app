import 'package:flutter/material.dart';
import '../widgets/event_detail_page.dart';

class BakingGoodsScreen extends StatelessWidget {
  const BakingGoodsScreen({super.key});

  @override
  Widget build(BuildContext context) => EventDetailPage(
    title: 'Baking Goods',
    subtitle: 'Freshly baked favourites, made to brighten your day.',
    image: 'assets/images/cake7.jpg',
    gallery: [
      'assets/images/cake7.jpg',
      'assets/images/cake3.jpg',
      'assets/images/cake8.jpg',
    ],
    description:
        'Discover a delicious selection of freshly baked cakes, pastries, and chocolate treats made by our bakers every day.',
    included: [
      'Celebration cakes',
      'Chocolate brownies and slices',
      'Fresh pastries and cupcakes',
      'Custom cake decorations',
      'Seasonal dessert specials',
    ],
    details: [
      'Available daily',
      'Visit us in store or speak with our team about a custom order.',
    ],
    bottomAction: FilledButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Back to Events'),
    ),
  );
}
