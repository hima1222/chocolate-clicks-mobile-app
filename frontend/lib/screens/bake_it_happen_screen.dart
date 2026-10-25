import 'package:flutter/material.dart';
import '../widgets/scheduled_event_page.dart';

class BakeItHappenScreen extends StatelessWidget {
  const BakeItHappenScreen({super.key});

  @override
  Widget build(BuildContext context) => ScheduledEventPage(
    title: 'Bake It Happen',
    subtitle: 'Mix, bake, and make something wonderful.',
    image: 'assets/images/bih1.jpg',
    gallery: [
      'assets/images/bih2.jpeg',
      'assets/images/bih3.jpeg',
      'assets/images/bih4.jpeg',
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
  );
}
