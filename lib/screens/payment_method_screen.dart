import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'card';

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 20),
                    // Title
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select your preferred payment method',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Credit/Debit Card Option
                    _buildPaymentMethodCard(
                      icon: Icons.credit_card,
                      title: 'Credit/Debit Card',
                      description: 'Visa, Mastercard, or other cards',
                      value: 'card',
                      onTap: () => setState(() => _selectedMethod = 'card'),
                    ),
                    const SizedBox(height: 15),
                    // Digital Wallet Option
                    _buildPaymentMethodCard(
                      icon: Icons.wallet,
                      title: 'Digital Wallet',
                      description: 'Apple Pay or Google Pay',
                      value: 'wallet',
                      onTap: () => setState(() => _selectedMethod = 'wallet'),
                    ),
                    const SizedBox(height: 15),
                    // Bank Transfer Option
                    _buildPaymentMethodCard(
                      icon: Icons.account_balance,
                      title: 'Bank Transfer',
                      description: 'Direct bank account transfer',
                      value: 'bank',
                      onTap: () => setState(() => _selectedMethod = 'bank'),
                    ),
                    const SizedBox(height: 15),
                    // UPI Option
                    _buildPaymentMethodCard(
                      icon: Icons.qr_code_2,
                      title: 'UPI Payment',
                      description: 'UPI enabled apps',
                      value: 'upi',
                      onTap: () => setState(() => _selectedMethod = 'upi'),
                    ),
                    const SizedBox(height: 50),
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedMethod == 'card') {
                            Navigator.pushNamed(context, '/add_card');
                          } else if (_selectedMethod == 'wallet') {
                            Navigator.pushNamed(context, '/digital_wallet');
                          } else if (_selectedMethod == 'bank') {
                            Navigator.pushNamed(context, '/bank_transfer');
                          } else if (_selectedMethod == 'upi') {
                            Navigator.pushNamed(context, '/upi_payment');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            245,
                            157,
                            74,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(isSelected ? 0.6 : 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(159, 245, 157, 74)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(159, 245, 157, 74).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color.fromARGB(159, 245, 157, 74),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'serif',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color.fromARGB(159, 245, 157, 74)
                      : Colors.white30,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Color.fromARGB(159, 245, 157, 74),
                        size: 14,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
