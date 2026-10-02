import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final String title, subtitle, image, description;
  final List<String> included, details, gallery;

  const EventDetailPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.description,
    required this.included,
    this.details = const [],
    this.gallery = const [],
  });

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFE8CB);
    const gold = Color(0xFFF5B568);
    return Scaffold(
      backgroundColor: const Color(0xFF1C100C),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: const Color(0xFF1C100C),
            foregroundColor: cream,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(image, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26,
                          Colors.transparent,
                          Color(0xFF1C100C),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'CHOCOLATE CLICKS EXPERIENCES',
                            style: TextStyle(
                              color: gold,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: const TextStyle(
                            color: cream,
                            fontSize: 36,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: cream,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            sliver: SliverList.list(
              children: [
                if (gallery.isNotEmpty) ...[
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          gallery[index],
                          width: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
                const Text(
                  'A little escape. A sweeter memory.',
                  style: TextStyle(
                    color: gold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'The experience',
                  style: TextStyle(
                    color: cream,
                    fontSize: 25,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF302019),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: gold.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What you will enjoy',
                        style: TextStyle(
                          color: cream,
                          fontSize: 22,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final item in included)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: gold,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: cream,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Plan your visit',
                  style: TextStyle(
                    color: cream,
                    fontSize: 25,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                for (final detail in details)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      detail,
                      style: const TextStyle(
                        color: gold,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                const Text(
                  'Ask the shop about availability and let us know about dietary or accessibility needs before your visit.',
                  style: TextStyle(color: Colors.white60, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: const Color(0xFF1C100C),
              padding: const EdgeInsets.all(18),
            ),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please contact the shop to reserve this experience.',
                ),
              ),
            ),
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('Plan this experience'),
          ),
        ),
      ),
    );
  }
}
