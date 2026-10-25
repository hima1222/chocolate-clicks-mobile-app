import 'package:flutter/material.dart';
import '../widgets/event_detail_page.dart';
import '../widgets/event_booking_button.dart';

class SummerCakePicnicsScreen extends StatelessWidget {
  const SummerCakePicnicsScreen({super.key});

  @override
  Widget build(BuildContext context) => EventDetailPage(
    title: 'Summer Cake Picnics',
    subtitle: 'Fresh air, good company, and a basket of sweetness.',
    image: 'assets/images/c5.jpeg',
    gallery: [
      'assets/images/c4.jpeg',
      'assets/images/cp3.jpg',
      'assets/images/cp4.jpg',
    ],
    description:
        'Make summer unforgettable with our Summer Cake Picnics! Enjoy a delightful outdoor experience featuring seasonal cakes, picnic treats, and chocolate delicacies in beautiful garden settings. Perfect for families and friends.',
    included: [
      'Seasonal cake selection',
      'Picnic basket with treats',
      'Outdoor garden seating',
      'Live music entertainment',
      'Photography session',
      'Refreshing beverages',
    ],
    details: [
      'Duration: 4 hours',
      'Price: Rs. 4,000 per person',
      'Date: Every Saturday & Sunday, 12:00 PM - 4:00 PM (Summer Season)',
    ],
    bottomAction: const EventBookingButton(eventTitle: 'Summer Cake Picnics'),
  );
}

