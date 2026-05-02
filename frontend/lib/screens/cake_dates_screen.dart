import 'package:flutter/material.dart';

class CakeDatesScreen extends StatelessWidget {
  const CakeDatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/event_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(color: Colors.black.withValues(alpha: 0.3)),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Cake Dates',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Event description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(49, 0, 0, 0),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color.fromARGB(159, 245, 157, 74),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sweeten your romantic moments with Cake Dates! Our specially curated dating experience features intimate settings, decadent chocolate desserts, and romantic ambiance. Perfect for couples looking to create unforgettable memories.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'serif',
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'What\'s Included:',
                            style: TextStyle(
                              color: Color.fromARGB(255, 245, 157, 74),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '• Romantic private seating\n• Curated dessert tasting menu\n• Sparkling beverages\n• Ambient lighting and music\n• Couples photography\n• Dessert recipe to recreate at home',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'serif',
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Duration: 2 hours\nPrice: Rs. 6,000 per couple\nDate: Every evening, 6:00 PM - 8:00 PM (Reservation required)',
                            style: TextStyle(
                              color: Color.fromARGB(255, 245, 157, 74),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'serif',
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Book Now button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking feature coming soon!'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            245,
                            157,
                            74,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
