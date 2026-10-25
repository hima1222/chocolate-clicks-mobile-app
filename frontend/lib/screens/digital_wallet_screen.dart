import 'package:flutter/material.dart';
import '../widgets/payment_page.dart';
import '../widgets/shop_page.dart';

class DigitalWalletScreen extends StatefulWidget {
  const DigitalWalletScreen({super.key});

  @override
  State<DigitalWalletScreen> createState() => _DigitalWalletScreenState();
}

class _DigitalWalletScreenState extends State<DigitalWalletScreen> {
  String _selectedWallet = 'googlepay';
  bool _isLoading = false;
  String? _userEmail;
  String? _userName;

  @override
  Widget build(BuildContext context) => PaymentPage(
    title: 'Digital Wallet',
    subtitle: 'Choose a wallet and add your account details.',

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Google Pay Option
        _buildWalletCard(
          icon: Icons.payment,
          title: 'Google Pay',
          description: 'Fast and secure payments',
          value: 'googlepay',
          color: Colors.blue,
          onTap: () => setState(() => _selectedWallet = 'googlepay'),
        ),
        const SizedBox(height: 15),
        // Apple Pay Option
        _buildWalletCard(
          icon: Icons.apple,
          title: 'Apple Pay',
          description: 'Quick and simple',
          value: 'applepay',
          color: shopCream,
          onTap: () => setState(() => _selectedWallet = 'applepay'),
        ),
        const SizedBox(height: 28),
        // Email/ID Section
        const Text(
          'Wallet Account',
          style: TextStyle(
            color: shopCream,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 12),
        // Email TextField
        TextFormField(
          onChanged: (value) => setState(() => _userEmail = value),
          decoration: InputDecoration(
            labelText: 'Email or Phone',
            labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
            hintText: 'your.email@example.com',
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
          ),
          style: const TextStyle(color: shopCream),
        ),
        const SizedBox(height: 16),
        // Name TextField
        TextFormField(
          onChanged: (value) => setState(() => _userName = value),
          decoration: InputDecoration(
            labelText: 'Account Holder Name',
            labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
            hintText: 'Your Name',
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
          ),
          style: const TextStyle(color: shopCream),
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
  );

  void _handleContinue() async {
    if (_userEmail == null || _userEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email or phone number'),
        ),
      );
      return;
    }

    if (_userName == null || _userName!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    setState(() => _isLoading = true);

    // Simulate wallet verification (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Navigate to payment summary with wallet details
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/payment_summary',
        arguments: {
          'method': 'wallet',
          'walletType': _selectedWallet,
          'email': _userEmail,
          'name': _userName,
        },
      );
    }
  }

  Widget _buildWalletCard({
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedWallet == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF493123) : shopBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? shopGold : shopGold.withValues(alpha: 0.18),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: shopCream,
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
                  color: isSelected ? shopGold : Colors.white30,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, color: shopGold, size: 14),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
