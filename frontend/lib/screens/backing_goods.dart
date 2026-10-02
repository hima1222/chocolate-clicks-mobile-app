import 'package:flutter/material.dart';
import '../widgets/event_detail_page.dart';

class BakingGoodsScreen extends StatelessWidget {
  const BakingGoodsScreen({super.key});

  @override
  Widget build(BuildContext context) => EventDetailPage(
    title: 'Baking Goods',
    subtitle: 'Discover the joy of making something by hand.',
    image: 'assets/images/workshops_bg.jpg',
    gallery: [
      'assets/images/workshops_collage1.jpg',
      'assets/images/workshops_collage2.jpg',
      'assets/images/workshops_collage3.jpg',
      'assets/images/workshops_collage4.jpg',
    ],
    description:
        'Step into a creative session at Chocolate Clicks and explore the craft behind your favourite baked treats. Discover baking ideas, learn about ingredients, and share a relaxed experience with fellow dessert lovers. Whether you are curious about baking or looking for inspiration for your next homemade creation, this is a sweet place to start.',
    included: [
      'Explore the craft of baking',
      'Discover ingredients and dessert inspiration',
      'Enjoy a creative experience with friends',
    ],
    details: [
      'Contact the shop for session times, pricing, and available activities.',
    ],
  );
}
