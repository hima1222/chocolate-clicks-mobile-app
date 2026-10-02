import 'package:flutter/material.dart';
import '../widgets/event_detail_page.dart';

class MaskPaintingWorkshopScreen extends StatelessWidget {
  const MaskPaintingWorkshopScreen({super.key});

  @override
  Widget build(BuildContext context) => EventDetailPage(
    title: 'Mask Painting Workshop',
    subtitle: 'Colour your afternoon with a little creativity.',
    image: 'assets/images/workshops_bg.jpg',
    gallery: [
      'assets/images/c6.jpg',
      'assets/images/workshops_collage2.jpg',
      'assets/images/workshops_collage3.jpg',
    ],
    description:
        'Unleash your creativity in our Mask Painting Workshop! Join us for a fun-filled session where you\'ll learn to paint beautiful masks using chocolate-themed designs. Perfect for beginners and experienced artists alike.',
    included: [
      'Professional painting supplies',
      'Chocolate-themed mask templates',
      'Expert instructor guidance',
      'Refreshments and snacks',
      'Take-home finished mask',
    ],
    details: [
      'Duration: 2 hours',
      'Price: Rs. 2,500 per person',
      'Date: Every Saturday, 2:00 PM - 4:00 PM',
    ],
  );
}
