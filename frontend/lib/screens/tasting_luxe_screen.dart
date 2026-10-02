import 'package:flutter/material.dart';
import '../widgets/event_detail_page.dart';

class TastingLuxeScreen extends StatelessWidget {
  const TastingLuxeScreen({super.key});

  @override
  Widget build(BuildContext context) => EventDetailPage(
    title: 'Tasting LUXE',
    subtitle: 'Discover the finer side of chocolate.',
    image: 'assets/images/cake7.jpg',
    gallery: [
      'assets/images/cake7.jpg',
      'assets/images/chocolate_treates.jpg',
      'assets/images/cake8.jpg',
    ],
    description:
        'Indulge in our premium Tasting LUXE experience! Sample our finest collection of artisanal chocolates, gourmet desserts, and exclusive confections crafted by master chocolatiers. A sensory journey for chocolate enthusiasts.',
    included: [
      'Premium chocolate tasting flight (12 varieties)',
      'Artisanal dessert pairings',
      'Expert sommelier guidance',
      'Luxury tasting notes booklet',
      'Gourmet refreshments',
    ],
    details: [
      'Duration: 1.5 hours',
      'Price: Rs. 5,000 per person',
      'Date: Every Friday, 7:00 PM - 8:30 PM',
    ],
  );
}
