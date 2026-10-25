import 'package:flutter/material.dart';

const shopBackground = Color(0xFF1C100C);
const shopSurface = Color(0xFF302019);
const shopCream = Color(0xFFFFE8CB);
const shopGold = Color(0xFFF5B568);

class ShopPage extends StatelessWidget {
  final String title, subtitle;
  final List<Widget> children;
  final VoidCallback? onBack;
  final Widget? bottomBar;
  const ShopPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shopBackground,
    bottomNavigationBar: bottomBar,
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38251B), shopBackground],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: onBack ?? () => Navigator.pop(context),
                  style: IconButton.styleFrom(backgroundColor: shopSurface),
                  icon: const Icon(Icons.arrow_back, color: shopCream),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: shopCream,
                      fontSize: 28,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'CHOCOLATE CLICKS',
              style: TextStyle(color: shopGold, fontSize: 11, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    ),
  );
}

class ShopPanel extends StatelessWidget {
  final Widget child;
  const ShopPanel({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: shopSurface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: shopGold.withValues(alpha: 0.18)),
    ),
    child: child,
  );
}

InputDecoration shopInput(String label, IconData icon) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: Colors.white70),
  prefixIcon: Icon(icon, color: shopGold, size: 20),
  filled: true,
  fillColor: shopBackground,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: shopGold),
  ),
  errorStyle: const TextStyle(color: Color(0xFFFFB4AB)),
);
