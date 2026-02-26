import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

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
                    // Back button and title in same row
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Events',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Subtopic
                    const Center(
                      child: Text(
                        'Sweeten Your Day with Chocolate Clicks!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'serif',
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Events List
                    Column(
                      children: [
                        // Event 1: Mask Painting Workshop
                        _buildEventCard(
                          context,
                          'Mask Painting Workshop..',
                          'Celebrate every occasion with our beautifully crafted cakes — from birthdays to weddings, made in your favorite flavors and designs.',
                          () {
                            Navigator.pushNamed(
                              context,
                              '/mask_painting_workshop',
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        // Event 2: Tasting LUXE
                        _buildEventCard(
                          context,
                          'Tasting LUXE..',
                          'Celebrate every occasion with our beautifully crafted cakes — from birthdays to weddings, made in your favorite flavors and designs.',
                          () {
                            Navigator.pushNamed(context, '/tasting_luxe');
                          },
                        ),
                        const SizedBox(height: 15),
                        // Event 3: Bake It Happen
                        _buildEventCard(
                          context,
                          'Bake It Happen..',
                          'Celebrate every occasion with our beautifully crafted cakes — from birthdays to weddings, made in your favorite flavors and designs.',
                          () {
                            Navigator.pushNamed(context, '/bake_it_happen');
                          },
                        ),
                        const SizedBox(height: 15),
                        // Event 4: Summer Cake Picnics
                        _buildEventCard(
                          context,
                          'Summer Cake Picnics..',
                          'Celebrate every occasion with our beautifully crafted cakes — from birthdays to weddings, made in your favorite flavors and designs.',
                          () {
                            Navigator.pushNamed(
                              context,
                              '/summer_cake_picnics',
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        // Event 5: Cake Dates
                        _buildEventCard(
                          context,
                          'Cake Dates..',
                          'Celebrate every occasion with our beautifully crafted cakes — from birthdays to weddings, made in your favorite flavors and designs.',
                          () {
                            Navigator.pushNamed(context, '/cake_dates');
                          },
                        ),
                      ],
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

  Widget _buildEventCard(
    BuildContext context,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:  Colors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromARGB(159, 245, 157, 74)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Event content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    //fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'serif',
                    color: const Color.fromARGB(159, 245, 157, 74),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // Navigation arrow
          IconButton(
            onPressed: onTap,
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Color.fromARGB(159, 245, 157, 74),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
