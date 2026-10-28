import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_pricing.dart';
import '../widgets/order_ui.dart';
import '../widgets/shop_page.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/payment_manager.dart';
import '../services/payment_service.dart';
import '../services/order_service.dart';
import '../widgets/payment_page.dart';
import 'orders_screen.dart';

class PaymentSummaryScreen extends StatefulWidget {
  const PaymentSummaryScreen({
    super.key,
    this.paymentData,
    this.resolveItems,
    this.quoteItems,
  });
  final Map<String, dynamic>? paymentData;
  final Future<List<CartItem>> Function(List<CartItem>)? resolveItems;
  final Future<OrderPricing> Function(List<CartItem>, String)? quoteItems;
  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController(text: 'Sri Lanka');
  final _form = GlobalKey<FormState>();
  List<CartItem> _items = [];
  bool _loading = true;
  bool _processing = false;
  String? _error;
  Order? _savedOrder;
  OrderPricing? _pricing;
  Timer? _cityDebounce;
  bool _quoting = false;
  int _quoteGeneration = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final selected =
          PaymentManager.checkoutItems ?? await CartService().fetchCartItems();
      final items = selected.isEmpty
          ? <CartItem>[]
          : await (widget.resolveItems?.call(selected) ??
                OrderService().resolveCheckoutItems(selected));
      if (mounted) {
        setState(() => _items = items);
        if (items.isNotEmpty) await _quote();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _items = [];
          _error = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _cityDebounce?.cancel();
    _quoteGeneration++;
    _address.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _quote() async {
    final generation = ++_quoteGeneration;
    setState(() => _quoting = true);
    try {
      final pricing =
          await (widget.quoteItems?.call(_items, _city.text.trim()) ??
              PaymentService().quoteProducts(_items, city: _city.text.trim()));
      if (mounted && generation == _quoteGeneration) {
        setState(() {
          _pricing = pricing;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted && generation == _quoteGeneration) {
        setState(() {
          _pricing = null;
          _error = error
              .toString()
              .replaceFirst('Exception: ', '')
              .replaceFirst('FormatException: ', '');
        });
      }
    } finally {
      if (mounted && generation == _quoteGeneration) {
        setState(() => _quoting = false);
      }
    }
  }

  void _cityChanged(String value) {
    _cityDebounce?.cancel();
    _quoteGeneration++;
    setState(() {
      _quoting = true;
      _pricing = null;
    });
    _cityDebounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted && _items.isNotEmpty) _quote();
    });
  }

  Future<void> _pay() async {
    if (!_form.currentState!.validate() || _pricing == null || _quoting) return;
    if (!AuthService().isAuthenticated) {
      setState(() => _error = 'Please log in to pay.');
      return;
    }
    setState(() {
      _processing = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    try {
      final result = _savedOrder != null
          ? await PaymentService().resumeCheckout(
              _savedOrder!.id,
              navigator: navigator,
              onProcessing: () {},
            )
          : await PaymentService().checkoutProducts(
              navigator: navigator,
              items: _items,
              expectedTotal: _pricing!.totalAmount,
              fromCart: PaymentManager.checkoutFromCart,
              billing: {
                'address': _address.text.trim(),
                'city': _city.text.trim(),
                'country': _country.text.trim(),
              },
              onOrderCreated: (order) {
                _savedOrder = order;
                if (order.fromCart) CartService().trackCheckout(order.id);
                if (mounted) setState(() {});
              },
              onProcessing: () {
                if (mounted) {
                  setState(() => _error = 'Verifying payment with PayHere...');
                }
              },
            );
      if (result.order.status == 'paid' && _savedOrder!.fromCart) {
        CartService().removePaidItems(result.order.id, _items);
      }
      if (result.order.status != 'paid') {
        if (mounted) {
          setState(
            () => _error =
                result.message ??
                'Your payment is awaiting verification. Check payment status before retrying.',
          );
        }
        return;
      }
      PaymentManager.checkoutItems = null;
      if (!mounted) return;
      final order =
          await OrderService().fetchOrderById(result.order.id) ?? _savedOrder!;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailsScreen(order: order),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.order.status == 'paid'
                ? 'Payment verified. Your order is confirmed.'
                : result.message ??
                      'Payment is pending verification. Refresh your order status before retrying.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error
              .toString()
              .replaceFirst('Exception: ', '')
              .replaceFirst('FormatException: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Widget _billingField(
    String label,
    TextEditingController controller, {
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      controller: controller,
      onChanged: controller == _city ? _cityChanged : null,
      enabled: !_processing && _savedOrder == null,
      maxLength: 200,
      maxLines: lines,
      style: const TextStyle(color: Colors.white),
      decoration: shopInput(
        label,
        controller == _city
            ? Icons.location_city_outlined
            : controller == _country
            ? Icons.public
            : Icons.location_on_outlined,
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Enter $label' : null,
    ),
  );
  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return PaymentPage(
      title: 'Order Summary',
      subtitle: 'Review your items and delivery details.',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_items.isEmpty && _error == null)
                    const Text(
                      'Your order is empty.',
                      style: TextStyle(color: Colors.white),
                    ),
                  const Text(
                    'YOUR TREATS',
                    style: TextStyle(
                      color: shopGold,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                  for (final item in _items) OrderItemTile(item: item),
                  const SizedBox(height: 20),
                  if (_quoting) const LinearProgressIndicator(color: shopGold),
                  if (_pricing != null) OrderPriceBreakdown(pricing: _pricing!),
                  const SizedBox(height: 8),
                  const Text(
                    'Delivery: Rs. 300 to Rs. 700 by area. Tax: 10% of product subtotal. Dispatch: No. 8 Stratford Avenue, Colombo 06.',
                    style: TextStyle(
                      color: Colors.white60,
                      height: 1.5,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Delivery To',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    user?.fullName ?? 'Please log in',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    user?.phone ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  _billingField('Delivery address', _address, lines: 2),
                  _billingField('City', _city),
                  _billingField('Country', _country),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose your payment method securely in PayHere checkout.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                  const SizedBox(height: 20),
                  if (_savedOrder == null)
                    FilledButton(
                      onPressed:
                          _processing ||
                              _quoting ||
                              _pricing == null ||
                              _items.isEmpty
                          ? null
                          : _pay,
                      child: Text(_processing ? 'Processing...' : 'Pay Now'),
                    ),
                  if (_savedOrder != null)
                    FilledButton(
                      onPressed: _processing ? null : _pay,
                      child: Text(
                        _processing ? 'Opening payment...' : 'Continue payment',
                      ),
                    ),
                  if (_savedOrder != null)
                    TextButton(
                      onPressed: _processing
                          ? null
                          : () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    OrderDetailsScreen(order: _savedOrder!),
                              ),
                            ),
                      child: const Text('View Order / Check Payment'),
                    ),
                  if (!_processing && _savedOrder == null)
                    TextButton(
                      onPressed: _load,
                      child: const Text('Reload Prices'),
                    ),
                ],
              ),
            ),
    );
  }
}
