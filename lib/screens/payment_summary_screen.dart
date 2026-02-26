import 'package:flutter/material.dart';

class PaymentSummaryScreen extends StatefulWidget {
  final Map<String, dynamic>? paymentData;

  const PaymentSummaryScreen({super.key, this.paymentData});

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Get payment data from arguments or use default
    final paymentData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final paymentMethod = paymentData['method'] as String? ?? 'card';
    final cardNumber = paymentData['cardNumber'] as String? ?? '';
    final cardHolder = paymentData['cardHolder'] as String? ?? '';

    // Sample order total (can be passed from previous screen)
    const double subtotal = 2500.0;
    const double deliveryFee = 150.0;
    const double taxAmount = 250.0;
    final double total = subtotal + deliveryFee + taxAmount;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/welcome_profile_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(color: Colors.black.withOpacity(0.5)),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: _isProcessing
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: _isProcessing ? Colors.grey : Colors.white,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 20),
                    // Title
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Order Items
                    _buildSectionTitle('Order Details'),
                    const SizedBox(height: 12),
                    _buildOrderItem('Chocolate Cake', 1, 1500.0),
                    _buildOrderItem('Brownies Pack', 2, 500.0),
                    const SizedBox(height: 24),
                    // Pricing Breakdown
                    _buildSectionTitle('Pricing'),
                    const SizedBox(height: 12),
                    _buildPricingRow(
                      'Subtotal',
                      'Rs. ${subtotal.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 10),
                    _buildPricingRow(
                      'Delivery Fee',
                      'Rs. ${deliveryFee.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 10),
                    _buildPricingRow(
                      'Tax (10%)',
                      'Rs. ${taxAmount.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    _buildPricingRow(
                      'Total',
                      'Rs. ${total.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                    const SizedBox(height: 30),
                    // Payment Method Section
                    _buildSectionTitle('Payment Method'),
                    const SizedBox(height: 12),
                    _buildPaymentMethodSummary(
                      paymentMethod,
                      cardNumber,
                      cardHolder,
                    ),
                    const SizedBox(height: 30),
                    // Delivery Details
                    _buildSectionTitle('Delivery To'),
                    const SizedBox(height: 12),
                    _buildDeliveryDetails(),
                    const SizedBox(height: 40),
                    // Pay Now Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _processPayment(context, total),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isProcessing
                              ? Colors.grey
                              : const Color.fromARGB(255, 245, 157, 74),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Pay Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'serif',
      ),
    );
  }

  Widget _buildOrderItem(String name, int quantity, double price) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: $quantity',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'serif',
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rs. ${(price * quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color.fromARGB(159, 245, 157, 74),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontFamily: 'serif',
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isBold
                ? const Color.fromARGB(159, 245, 157, 74)
                : Colors.white,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontFamily: 'serif',
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSummary(
    String method,
    String cardNumber,
    String cardHolder,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getPaymentMethodIcon(method),
                color: const Color.fromARGB(159, 245, 157, 74),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _getPaymentMethodName(method),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
          if (method == 'card' && cardNumber.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Card: ${cardNumber.substring(cardNumber.length - 4).padLeft(cardNumber.length, '*')}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'serif',
              ),
            ),
            if (cardHolder.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Cardholder: $cardHolder',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'serif',
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Himara Perera',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '40/J, MC Road, Matale, Sri Lanka',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '+94 701 234 567',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Estimated delivery: 30-45 minutes',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.wallet;
      case 'bank':
        return Icons.account_balance;
      case 'upi':
        return Icons.qr_code_2;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'card':
        return 'Credit/Debit Card';
      case 'wallet':
        return 'Digital Wallet';
      case 'bank':
        return 'Bank Transfer';
      case 'upi':
        return 'UPI Payment';
      default:
        return 'Unknown Method';
    }
  }

  Future<void> _processPayment(BuildContext context, double amount) async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // Simulate random success/failure (80% success rate)
    final isSuccess = DateTime.now().millisecond % 10 > 2;

    if (mounted) {
      setState(() => _isProcessing = false);

      if (isSuccess) {
        // Navigate to success screen
        Navigator.pushReplacementNamed(
          context,
          '/payment_success',
          arguments: {
            'amount': amount,
            'orderId': 'CHC${DateTime.now().millisecondsSinceEpoch % 1000000}',
            'paymentMethod': 'card',
          },
        );
      } else {
        // Navigate to failure screen
        Navigator.pushReplacementNamed(
          context,
          '/payment_failure',
          arguments: {
            'amount': amount,
            'reason': 'Payment declined. Please try another card.',
          },
        );
      }
    }
  }
}
