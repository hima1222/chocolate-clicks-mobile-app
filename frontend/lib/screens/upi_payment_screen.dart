import 'package:flutter/material.dart';
import '../widgets/payment_page.dart';
import '../widgets/shop_page.dart';

class UPIPaymentScreen extends StatefulWidget {
  const UPIPaymentScreen({super.key});

  @override
  State<UPIPaymentScreen> createState() => _UPIPaymentScreenState();
}

class _UPIPaymentScreenState extends State<UPIPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUPIApp;
  String _upiId = '';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _upiApps = [
    {
      'name': 'Google Pay',
      'icon': Icons.payment,
      'color': Colors.blue,
      'id': 'googlepay',
    },
    {
      'name': 'PhonePe',
      'icon': Icons.phone_android,
      'color': const Color(0xFF5F6EF7),
      'id': 'phonepe',
    },
    {
      'name': 'Paytm',
      'icon': Icons.wallet_travel,
      'color': const Color(0xFF0066cc),
      'id': 'paytm',
    },
    {
      'name': 'WhatsApp Pay',
      'icon': Icons.chat,
      'color': Colors.green,
      'id': 'whatsapp',
    },
    {
      'name': 'BHIM',
      'icon': Icons.account_balance,
      'color': Colors.orange,
      'id': 'bhim',
    },
    {
      'name': 'Other UPI App',
      'icon': Icons.qr_code_2,
      'color': Colors.purple,
      'id': 'other',
    },
  ];

  @override
  Widget build(BuildContext context) => PaymentPage(
    title: 'UPI Payment',
    subtitle: 'Choose your UPI app for your next sweet purchase.',
    onBack: _isLoading ? () {} : () => Navigator.of(context).pop(),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select UPI App
          const Text(
            'Select UPI App *',
            style: TextStyle(
              color: shopCream,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 15),
          // UPI App Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent:
                  125 + MediaQuery.textScalerOf(context).scale(12) * 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _upiApps.length,
            itemBuilder: (context, index) {
              final app = _upiApps[index];
              final isSelected = _selectedUPIApp == app['id'];
              return _buildUPIAppCard(
                app: app,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedUPIApp = app['id']);
                },
              );
            },
          ),
          const SizedBox(height: 28),
          // UPI ID Input
          const Text(
            'Enter UPI ID *',
            style: TextStyle(
              color: shopCream,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            onChanged: (value) => setState(() => _upiId = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your UPI ID';
              }
              if (!value.contains('@')) {
                return 'Invalid UPI ID format';
              }
              if (value.length < 5) {
                return 'UPI ID is too short';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'UPI ID',
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
              hintText: 'your.name@upi',
              hintStyle: TextStyle(color: Colors.white54),
              filled: true,
              fillColor: shopBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: shopGold, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            style: const TextStyle(color: shopCream),
          ),
          const SizedBox(height: 28),
          // Benefits Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: shopGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: shopGold.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'UPI Benefits',
                        style: TextStyle(
                          color: shopCream,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBenefitRow('⚡', 'Instant payment processing'),
                const SizedBox(height: 8),
                _buildBenefitRow('🔒', 'Secure and encrypted'),
                const SizedBox(height: 8),
                _buildBenefitRow('💬', 'No need to enter card details'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: shopGold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: shopGold.withValues(alpha: 0.5),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(shopCream),
                      ),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(
                        color: shopBackground,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildBenefitRow(String emoji, String text) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'serif',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUPIAppCard({
    required Map<String, dynamic> app,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF493123) : shopBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? shopGold : shopGold.withValues(alpha: 0.18),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (app['color'] as Color).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                app['icon'] as IconData,
                color: app['color'] as Color,
                size: 32,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              app['name'] as String,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: shopCream,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'serif',
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: shopGold,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUPIApp == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a UPI app')));
      return;
    }

    setState(() => _isLoading = true);

    // Simulate UPI verification (2.5 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));

    setState(() => _isLoading = false);

    // Navigate to payment summary with UPI details
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/payment_summary',
        arguments: {
          'method': 'upi',
          'upiApp': _selectedUPIApp,
          'upiId': _upiId,
        },
      );
    }
  }
}
