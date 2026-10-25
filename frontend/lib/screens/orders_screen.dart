import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/cart_service.dart';
import '../widgets/confirmation_email_status.dart';
import '../widgets/shop_page.dart';
import '../widgets/order_ui.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.loadOrders});
  final Future<List<Order>> Function()? loadOrders;
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> _orders;
  int _filter = 0;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _orders =
        widget.loadOrders?.call() ??
        OrderService().fetchUserOrders(AuthService().currentUser?.id ?? '');
  }

  Future<void> _refresh() async {
    setState(_reload);
    try {
      await _orders;
    } catch (_) {}
  }

  bool _active(Order order) =>
      order.status != OrderStatus.completed &&
      order.status != OrderStatus.cancelled;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<Order>>(
    future: _orders,
    builder: (context, snapshot) {
      final orders = snapshot.data ?? [];
      final filtered = orders
          .where(
            (order) =>
                _filter == 0 ||
                (_filter == 1
                    ? _active(order)
                    : order.status == OrderStatus.completed),
          )
          .toList();
      return OrderPage(
        title: 'Order Details',
        subtitle: 'Your sweet moments, all in one place.',
        onRefresh: _refresh,
        children: [
          ShopPanel(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: shopGold.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: shopGold,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Made for you',
                        style: TextStyle(
                          color: shopCream,
                          fontSize: 21,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${orders.length} ${orders.length == 1 ? 'order' : 'orders'}  /  ${orders.where(_active).length} in progress',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              for (var i = 0; i < 3; i++)
                ChoiceChip(
                  label: Text(['All orders', 'In progress', 'Completed'][i]),
                  selected: _filter == i,
                  onSelected: (_) => setState(() => _filter = i),
                  selectedColor: shopGold,
                  backgroundColor: shopSurface,
                  labelStyle: TextStyle(
                    color: _filter == i ? shopBackground : shopCream,
                  ),
                  showCheckmark: false,
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (snapshot.connectionState != ConnectionState.done)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: shopGold)),
            )
          else if (snapshot.hasError)
            ShopPanel(
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    color: shopGold,
                    size: 36,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load your orders.',
                    style: TextStyle(color: shopCream),
                  ),
                  TextButton(
                    onPressed: _refresh,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            )
          else if (filtered.isEmpty)
            ShopPanel(
              child: Column(
                children: [
                  const Icon(
                    Icons.bakery_dining_outlined,
                    color: shopGold,
                    size: 44,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'A little sweetness awaits',
                    style: TextStyle(
                      color: shopCream,
                      fontFamily: 'serif',
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orders.isEmpty
                        ? 'Your orders will appear here after checkout.'
                        : 'No orders in this category yet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, height: 1.5),
                  ),
                ],
              ),
            )
          else
            for (final order in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: shopSurface,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => OrderDetailsScreen(order: order),
                        ),
                      );
                      if (mounted) setState(_reload);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: shopGold.withValues(alpha: .2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  orderDate(order.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              OrderBadge(
                                order.status.displayName,
                                good: order.status == OrderStatus.completed,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            order.eventTitle ??
                                (order.items.isEmpty
                                    ? 'Chocolate Clicks order'
                                    : order.items.first.name),
                            style: const TextStyle(
                              color: shopCream,
                              fontSize: 19,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.eventTitle != null
                                ? 'Reserved experience'
                                : '${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} ${order.items.fold<int>(0, (sum, item) => sum + item.quantity) == 1 ? 'treat' : 'treats'} in your order',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  orderMoney(order.totalAmount),
                                  style: const TextStyle(
                                    color: shopGold,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Text(
                                'View progress',
                                style: TextStyle(
                                  color: shopCream,
                                  fontSize: 12,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: shopGold,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ],
      );
    },
  );
}

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.order, this.loadOrder});
  final Order order;
  final Future<Order?> Function(String)? loadOrder;
  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Order _order = widget.order;
  bool _loading = false;
  bool _paying = false;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _retryPayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retry payment?'),
        content: const Text(
          'If you were charged, refresh the payment status and allow time for verification before retrying. Retrying may charge you again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Wait'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue to PayHere'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _paying = true);
    try {
      final result = await PaymentService().resumeCheckout(
        _order.id,
        onProcessing: () {},
      );
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.order.status == 'paid'
                ? 'Payment verified. Your order is confirmed.'
                : result.message ??
                      'Payment is pending verification. Refresh status shortly.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final order =
        await (widget.loadOrder?.call(_order.id) ??
            OrderService().fetchOrderById(_order.id));
    if (!mounted) return;
    if (order?.paymentStatus == 'paid') {
      await PaymentService().clearPaidCheckoutDraft(order!);
      if (!mounted) return;
    }
    if (order?.paymentStatus == 'paid' && order!.fromCart) {
      CartService().removePaidItems(order.id, order.items);
    }
    setState(() {
      _loading = false;
      if (order != null) _order = order;
    });
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to refresh order. Try again.')),
      );
    }
  }

  Widget _timeline() {
    final stages = _order.eventTitle != null
        ? [OrderStatus.pending, OrderStatus.confirmed, OrderStatus.completed]
        : [
            OrderStatus.pending,
            OrderStatus.confirmed,
            OrderStatus.preparing,
            OrderStatus.ready,
            OrderStatus.completed,
          ];
    final active = stages.indexOf(_order.status);
    const descriptions = {
      OrderStatus.pending: 'Waiting for payment verification',
      OrderStatus.confirmed: 'Your order has been accepted',
      OrderStatus.preparing: 'Your treats are being prepared',
      OrderStatus.ready: 'Packed and ready for delivery',
      OrderStatus.completed: 'Enjoy your Chocolate Clicks treats',
    };
    return ShopPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Follow your order',
            style: TextStyle(
              color: shopCream,
              fontSize: 19,
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (_order.status == OrderStatus.cancelled)
            const Text(
              'This order has been cancelled.',
              style: TextStyle(color: Colors.white70),
            )
          else
            for (var i = 0; i < stages.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i <= active ? shopGold : shopBackground,
                        border: Border.all(
                          color: i <= active
                              ? shopGold
                              : const Color(0xFF71503A),
                        ),
                      ),
                      child: Icon(
                        i < active
                            ? Icons.check_rounded
                            : i == active
                            ? Icons.radio_button_checked
                            : Icons.circle_outlined,
                        color: i <= active ? shopBackground : Colors.white38,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stages[i].displayName,
                            style: TextStyle(
                              color: i <= active ? shopCream : Colors.white54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _order.eventTitle != null
                                ? (i == 0
                                      ? 'Waiting for payment verification'
                                      : i == 1
                                      ? 'Your experience is reserved'
                                      : 'Experience completed')
                                : descriptions[stages[i]]!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i == active) const OrderBadge('Current'),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paid = _order.paymentStatus == 'paid';
    final progress = _order.status == OrderStatus.cancelled
        ? 0.0
        : _order.status.index / 4;
    return OrderPage(
      title: 'Order Progress',
      subtitle: 'A little sweetness, on its way.',
      onRefresh: _refresh,
      action: IconButton(
        tooltip: 'Refresh order',
        onPressed: _loading || _paying ? null : _refresh,
        icon: const Icon(Icons.refresh_rounded, color: shopGold),
      ),
      children: [
        if (_loading) const LinearProgressIndicator(color: shopGold),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6E472C), shopSurface],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: shopGold.withValues(alpha: .35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: shopGold.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _order.status == OrderStatus.completed
                          ? Icons.celebration_outlined
                          : Icons.local_shipping_outlined,
                      color: shopGold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ORDER STATUS',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _order.status.displayName,
                          style: const TextStyle(
                            color: shopCream,
                            fontSize: 26,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 6,
                  color: shopGold,
                  backgroundColor: shopBackground,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OrderBadge(
                    paid
                        ? 'Payment verified'
                        : (_order.paymentStatus == null
                              ? 'Payment not recorded'
                              : 'Payment: ${_order.paymentStatus}'),
                    good: paid,
                  ),
                  OrderBadge(orderDate(_order.createdAt)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${_order.id}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy order ID',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _order.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order ID copied')),
                      );
                    },
                    icon: const Icon(
                      Icons.copy_outlined,
                      color: shopGold,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _timeline(),
        const SizedBox(height: 20),
        ShopPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your order',
                style: TextStyle(
                  color: shopCream,
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_order.eventTitle != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    _order.eventTitle!,
                    style: const TextStyle(color: shopCream),
                  ),
                ),
              for (final item in _order.items) OrderItemTile(item: item),
              const Divider(color: Color(0xFF674934)),
              if (_order.pricing != null)
                OrderPriceBreakdown(pricing: _order.pricing!)
              else
                Text(
                  'Total: ${orderMoney(_order.totalAmount)}',
                  style: const TextStyle(
                    color: shopGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        if (_order.deliveryAddress?.isNotEmpty == true) ...[
          const SizedBox(height: 20),
          ShopPanel(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, color: shopGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery to',
                        style: TextStyle(
                          color: shopCream,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _order.deliveryAddress!,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (!paid &&
            _order.paymentStatus != 'chargedback' &&
            _order.status != OrderStatus.cancelled)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: shopGold,
              foregroundColor: shopBackground,
              padding: const EdgeInsets.all(18),
            ),
            onPressed: _paying || _loading ? null : _retryPayment,
            icon: const Icon(Icons.lock_outline),
            label: Text(_paying ? 'Processing...' : 'Continue / Retry Payment'),
          ),
        if (paid) ShopPanel(child: ConfirmationEmailStatus(orderId: _order.id)),
      ],
    );
  }
}
