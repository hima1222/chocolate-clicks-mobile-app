import 'package:flutter/material.dart';
import 'shop_page.dart';

class CompactShopGrid extends StatelessWidget {
  final List<Widget> children;
  const CompactShopGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 260 ? 2 : 1;
      final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 16,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class CompactShopCard extends StatelessWidget {
  final String title, image, label;
  final String? description;
  final VoidCallback onTap;
  const CompactShopCard({
    super.key,
    required this.title,
    required this.image,
    required this.label,
    required this.onTap,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return Material(
      color: shopSurface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(image, height: 110, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: scaler.scale(18) * 1.25 * 3,
                    child: Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: shopCream,
                        fontFamily: 'serif',
                        fontSize: 18,
                        height: 1.25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      height: scaler.scale(12) * 1.4 * 2,
                      child: Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(color: shopGold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        color: shopGold,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
