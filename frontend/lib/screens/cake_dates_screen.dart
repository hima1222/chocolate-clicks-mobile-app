import 'package:flutter/material.dart';
import '../widgets/event_detail_page.dart';

class CakeDatesScreen extends StatelessWidget {
  const CakeDatesScreen({super.key});

  @override
  Widget build(BuildContext context) => EventDetailPage(
    title: 'Cake Dates',
    subtitle: 'A table for two. A moment to savour.',
    image: 'assets/images/cake8.jpg',
    gallery: [
      'assets/images/cake7.jpg',
      'assets/images/cake3.jpg',
      'assets/images/cake8.jpg',
    ],
    description:
        'Sweeten your romantic moments with Cake Dates! Our specially curated dating experience features intimate settings, decadent chocolate desserts, and romantic ambiance. Perfect for couples looking to create unforgettable memories.',
    included: [
      'Romantic private seating',
      'Curated dessert tasting menu',
      'Sparkling beverages',
      'Ambient lighting and music',
      'Couples photography',
      'Dessert recipe to recreate at home',
    ],
    details: [
      'Duration: 2 hours',
      'Price: Rs. 6,000 per couple',
      'Date: Every evening, 6:00 PM - 8:00 PM (Reservation required)',
    ],
  );
}
