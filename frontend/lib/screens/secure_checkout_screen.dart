import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/welcome_highlights.dart';

class SecureCheckoutScreen extends StatefulWidget {
  const SecureCheckoutScreen({
    super.key,
    required this.payment,
    required this.launch,
  });
  final Map<String, dynamic> payment;
  final Future<String?> Function(Map<String, dynamic>) launch;
  @override
  State<SecureCheckoutScreen> createState() => _SecureCheckoutScreenState();
}

class _SecureCheckoutScreenState extends State<SecureCheckoutScreen> {
  bool _busy = false;
  String? _error;
  String _method = '';
  Future<void> _pay() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final message = await widget.launch({
        ...widget.payment,
        if (kIsWeb && _method.isNotEmpty) 'payment_method': _method,
      });
      if (!mounted) return;
      if (message == null) {
        Navigator.pop(context, 'submitted');
      } else {
        setState(() => _error = message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Unable to open secure checkout. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: welcomeBackground,
    appBar: AppBar(
      title: const Text('Payment'),
      backgroundColor: welcomeBackground,
      foregroundColor: welcomeCream,
      surfaceTintColor: Colors.transparent,
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: welcomeAccent,
                size: 44,
              ),
              const SizedBox(height: 20),
              const Text(
                'Complete your payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: welcomeCream,
                  fontSize: 28,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose a payment method, then enter your card details securely on PayHere.',
                textAlign: TextAlign.center,
                style: TextStyle(color: welcomeMuted, height: 1.6),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: welcomeSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: welcomeAccent.withValues(alpha: .25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.payment['items']?.toString() ?? 'Your order',
                      style: const TextStyle(color: welcomeCream, fontSize: 18),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'TOTAL TO PAY',
                      style: TextStyle(
                        color: welcomeMuted,
                        letterSpacing: 1.5,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.payment['currency']} ${widget.payment['amount']}',
                      style: const TextStyle(
                        color: welcomeAccent,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (kIsWeb)
                      DropdownButtonFormField<String>(
                        initialValue: _method,
                        dropdownColor: welcomeSurface,
                        style: const TextStyle(color: welcomeCream),
                        decoration: const InputDecoration(
                          labelText: 'Payment method',
                          labelStyle: TextStyle(color: welcomeMuted),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: welcomeMuted),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '',
                            child: Text('Choose on PayHere'),
                          ),
                          DropdownMenuItem(value: 'VISA', child: Text('Visa')),
                          DropdownMenuItem(
                            value: 'MASTER',
                            child: Text('Mastercard'),
                          ),
                          DropdownMenuItem(
                            value: 'AMEX',
                            child: Text('American Express'),
                          ),
                        ],
                        onChanged: _busy
                            ? null
                            : (value) => setState(() => _method = value ?? ''),
                      ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: _busy ? null : _pay,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.credit_card),
                      label: Text(
                        _busy ? 'Opening PayHere...' : 'Continue to PayHere',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: welcomeAccent,
                        foregroundColor: welcomeBackground,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.orangeAccent),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your order is confirmed only after PayHere verifies payment. If you cancel, you can continue payment from My Orders.',
                      style: TextStyle(
                        color: welcomeMuted,
                        fontSize: 12,
                        height: 1.6,
                      ),
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
