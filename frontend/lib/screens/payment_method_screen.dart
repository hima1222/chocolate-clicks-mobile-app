import 'package:flutter/material.dart';
import '../widgets/payment_page.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});
  @override
  Widget build(BuildContext context) => PaymentPage(
    title: 'Secure Payment',
    subtitle: 'Pay with PayHere',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review your order and delivery details, then choose an available payment method in PayHere checkout.',
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.pushNamed(context, '/payment_summary'),
          child: const Text('Review Order'),
        ),
      ],
    ),
  );
}
