import 'package:flutter/material.dart';
import '../models/order_pricing.dart';
import '../models/cart_item.dart';
import 'shop_page.dart';

String orderMoney(double value) => 'Rs. ${value.toStringAsFixed(2)}';
String orderDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final date = value.toLocal();
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class OrderPage extends StatelessWidget {
  const OrderPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.onRefresh,
    this.action,
  });
  final String title, subtitle;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.maybePop(context),
              style: IconButton.styleFrom(backgroundColor: shopSurface),
              icon: const Icon(Icons.arrow_back, color: shopCream),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: shopCream,
                  fontSize: 26,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'CHOCOLATE CLICKS',
          style: TextStyle(color: shopGold, fontSize: 11, letterSpacing: 2.5),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(color: shopCream, fontSize: 18, height: 1.4),
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: shopGold,
          surface: shopSurface,
          onSurface: shopCream,
          onPrimary: shopBackground,
        ),
      ),
      child: Scaffold(
        backgroundColor: shopBackground,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF432C1F), shopBackground],
            ),
          ),
          child: SafeArea(
            child: onRefresh == null
                ? list
                : RefreshIndicator(
                    color: shopGold,
                    onRefresh: onRefresh!,
                    child: list,
                  ),
          ),
        ),
      ),
    );
  }
}

class OrderBadge extends StatelessWidget {
  const OrderBadge(this.label, {super.key, this.good = false});
  final String label;
  final bool good;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: (good ? const Color(0xFF9FCCAC) : shopGold).withValues(alpha: .14),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: good ? const Color(0xFFC5E4CE) : shopGold,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item});
  final CartItem item;
  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: shopGold.withValues(alpha: .12),
      child: const Icon(Icons.bakery_dining_outlined, color: shopGold),
    );
    final image = item.imageUrl.isEmpty
        ? fallback
        : item.imageUrl.startsWith('http')
        ? Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stack) => fallback,
          )
        : Image.asset(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stack) => fallback,
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: 54, height: 58, child: image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: shopCream,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  orderMoney(item.totalPrice),
                  style: const TextStyle(
                    color: shopGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderPriceBreakdown extends StatelessWidget {
  const OrderPriceBreakdown({super.key, required this.pricing});
  final OrderPricing pricing;
  Widget _row(String label, double value, {bool total = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: total ? shopCream : Colors.white70,
              fontSize: total ? 17 : 14,
              fontWeight: total ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          fit: FlexFit.tight,
          child: Text(
            orderMoney(value),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: total ? shopGold : shopCream,
              fontSize: total ? 18 : 14,
              fontWeight: total ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _row('Subtotal', pricing.subtotal),
      _row('Delivery fee', pricing.deliveryFee),
      _row('Service charge', pricing.serviceCharge),
      _row(
        'Tax (${pricing.taxRate.toStringAsFixed(pricing.taxRate % 1 == 0 ? 0 : 1)}%)',
        pricing.taxAmount,
      ),
      const Divider(color: Color(0xFF674934), height: 26),
      _row('Total', pricing.totalAmount, total: true),
    ],
  );
}
