import 'package:flutter/material.dart';

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 20),
                      // Title
                      const Text(
                        'UPI Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Select your UPI app and enter UPI ID',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Select UPI App
                      const Text(
                        'Select UPI App *',
                        style: TextStyle(
                          color: Colors.white,
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
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
                      const SizedBox(height: 40),
                      // UPI ID Input
                      const Text(
                        'Enter UPI ID *',
                        style: TextStyle(
                          color: Colors.white,
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
                          labelStyle: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          hintText: 'your.name@upi',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(159, 245, 157, 74),
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 40),
                      // Benefits Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
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
                                const Text(
                                  'UPI Benefits',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildBenefitRow('⚡', 'Instant payment processing'),
                            const SizedBox(height: 8),
                            _buildBenefitRow('🔒', 'Secure and encrypted'),
                            const SizedBox(height: 8),
                            _buildBenefitRow(
                              '💬',
                              'No need to enter card details',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleContinue,
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
                            disabledBackgroundColor: const Color.fromARGB(
                              255,
                              245,
                              157,
                              74,
                            ).withOpacity(0.5),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
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
          ),
        ],
      ),
    );
  }

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
          color: Colors.black.withOpacity(isSelected ? 0.6 : 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(159, 245, 157, 74)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (app['color'] as Color).withOpacity(0.2),
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
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
                  color: Color.fromARGB(159, 245, 157, 74),
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
