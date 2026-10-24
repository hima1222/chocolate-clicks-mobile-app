import 'package:flutter/material.dart';
import 'shop_page.dart';

class PaymentPage extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  final VoidCallback? onBack;

  const PaymentPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: const ColorScheme.dark(
        primary: shopGold,
        secondary: shopGold,
        surface: shopSurface,
        onSurface: shopCream,
        onPrimary: shopBackground,
        error: Color(0xFFFFB4AB),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: shopGold,
        selectionColor: Color(0x665F4430),
        selectionHandleColor: shopGold,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        errorStyle: TextStyle(color: Color(0xFFFFB4AB)),
        counterStyle: TextStyle(color: Colors.white54),
      ),
    ),
    child: ShopPage(
      title: title,
      subtitle: subtitle,
      onBack: onBack,
      children: [ShopPanel(child: child)],
    ),
  );
}
