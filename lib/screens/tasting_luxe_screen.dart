import 'package:flutter/material.dart';

class TastingLuxeScreen extends StatelessWidget {
  const TastingLuxeScreen({super.key});

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
          Container(color: Colors.black.withOpacity(0.3)),
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
                        'Tasting LUXE',
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
                            'Indulge in our premium Tasting LUXE experience! Sample our finest collection of artisanal chocolates, gourmet desserts, and exclusive confections crafted by master chocolatiers. A sensory journey for chocolate enthusiasts.',
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
                            '• Premium chocolate tasting flight (12 varieties)\n• Artisanal dessert pairings\n• Expert sommelier guidance\n• Luxury tasting notes booklet\n• Gourmet refreshments',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'serif',
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Duration: 1.5 hours\nPrice: Rs. 5,000 per person\nDate: Every Friday, 7:00 PM - 8:30 PM',
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
