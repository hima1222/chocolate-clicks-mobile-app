import 'package:flutter/material.dart';
import '../widgets/event_detail_page.dart';

class BakeItHappenScreen extends StatelessWidget {
  const BakeItHappenScreen({super.key});

  @override
  Widget build(BuildContext context) => EventDetailPage(
    title: 'Bake It Happen',
    subtitle: 'Mix, bake, and make something wonderful.',
    image: 'assets/images/workshops_bg.jpg',
    gallery: [
      'assets/images/workshops_collage2.jpg',
      'assets/images/cake3.jpg',
      'assets/images/cake8.jpg',
    ],
    description:
        'Turn your baking dreams into reality at Bake It Happen! Join our interactive baking workshop where you\'ll learn to create stunning chocolate desserts from scratch. Perfect for aspiring bakers and dessert lovers.',
    included: [
      'Professional baking equipment',
      'Premium ingredients',
      'Step-by-step instruction',
      'Recipe booklet to take home',
      'Finished baked goods to enjoy',
    ],
    details: [
      'Duration: 3 hours',
      'Price: Rs. 3,500 per person',
      'Date: Every Sunday, 10:00 AM - 1:00 PM',
    ],
  );
}
