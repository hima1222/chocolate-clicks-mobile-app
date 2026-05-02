import 'package:flutter/material.dart';

class CookiesType1Screen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const CookiesType1Screen({super.key, this.product});

  @override
  State<CookiesType1Screen> createState() => _CookiesType1ScreenState();
}

class _CookiesType1ScreenState extends State<CookiesType1Screen> {
  Map<String, dynamic>? get product => widget.product;

  String selectedSize = 'Medium';
  String selectedTopping = 'Cookies_type1';
  String selectedFrosting = 'Chocolate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      product?['title'] as String? ?? 'Cookies Type 1',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Image.asset(
                product?['image'] as String? ?? 'assets/images/cookies_type1.jpg',
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product?['description'] as String? ??
                      'Soft baked cookies with a balanced sweetness and rich texture.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedSize,
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: ['Small', 'Medium', 'Large'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedSize = value!),
                    ),

                    const SizedBox(height: 20),
                    const Text('Toppings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedTopping,
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: ['Cookies_type1', 'Chocolate Chips', 'Nuts'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedTopping = value!),
                    ),

                    const SizedBox(height: 20),
                    const Text('Frosting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedFrosting,
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: ['Chocolate', 'Vanilla', 'Cream Cheese'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedFrosting = value!),
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reviews coming soon!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[800],
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Review', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.grey[900],
                child: Text(
                  product?['description'] as String? ??
                      'Fresh cookies baked to a soft center and golden edge.',
                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
