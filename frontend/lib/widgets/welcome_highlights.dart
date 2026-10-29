import 'package:flutter/material.dart';
import 'app_image.dart';

const welcomeBackground = Color(0xFF201710);
const welcomeSurface = Color(0xFF33271F);
const welcomeCream = Color(0xFFE6D3BD);
const welcomeAccent = Color(0xFFD6A36F);
const welcomeMuted = Color(0xFFBDA892);

class WelcomeEventBanner extends StatelessWidget {
  final String image, title;
  final int index, count;
  final VoidCallback onTap;
  const WelcomeEventBanner({
    super.key,
    required this.image,
    required this.title,
    required this.index,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'View cafe events: $title',
    child: Material(
      color: welcomeSurface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          key: const ValueKey('welcome-event-frame'),
          height:
              180 +
              (MediaQuery.textScalerOf(context).scale(16) - 16).clamp(0, 32),
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                child: SizedBox.expand(
                  key: ValueKey(image),
                  child: AppImage.asset(
                    image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x221C140F), Color(0xE6201710)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OUR FEATURED EVENTS',
                      style: TextStyle(
                        color: welcomeCream,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: welcomeCream,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.arrow_forward,
                          color: welcomeAccent,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (var i = 0; i < count; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 5,
                            width: i == index ? 16 : 5,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: i == index
                                  ? welcomeAccent
                                  : welcomeMuted.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class WelcomeCategoryPill extends StatelessWidget {
  final String label;
  final bool available;
  final VoidCallback onTap;
  const WelcomeCategoryPill({
    super.key,
    required this.label,
    required this.onTap,
    this.available = true,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: available ? welcomeSurface : const Color(0xFF2A211B),
    shape: StadiumBorder(
      side: BorderSide(
        color: welcomeMuted.withValues(alpha: available ? 0.4 : 0.18),
      ),
    ),
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Text(
          label,
          style: TextStyle(
            color: available ? welcomeCream : welcomeMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
