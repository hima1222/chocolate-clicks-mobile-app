import 'package:flutter/material.dart';
import '../widgets/payment_page.dart';
import '../widgets/shop_page.dart';
import 'package:flutter/services.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _saveCard = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    value = value.replaceAll(' ', '');
    if (value.isEmpty) return '';
    StringBuffer result = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        result.write(' ');
      }
      result.write(value[i]);
    }
    return result.toString();
  }

  String _maskCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.length < 4) return cleanNumber;
    final masked =
        '*' * (cleanNumber.length - 4) +
        cleanNumber.substring(cleanNumber.length - 4);
    return _formatCardNumber(masked);
  }

  @override
  Widget build(BuildContext context) => PaymentPage(
    title: 'Add New Card',
    subtitle: 'Enter your card details to continue.',

    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card preview
          _buildCardPreview(),
          const SizedBox(height: 28),
          // Card Number
          _buildTextField(
            controller: _cardNumberController,
            label: 'Card Number',
            hint: '1234 5678 9012 3456',
            keyboardType: TextInputType.number,
            maxLength: 19,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            onChanged: (value) {
              _cardNumberController.value = TextEditingValue(
                text: _formatCardNumber(value),
                selection: TextSelection.fromPosition(
                  TextPosition(offset: _formatCardNumber(value).length),
                ),
              );
            },
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Card number is required';
              }
              final cleanNumber = value!.replaceAll(' ', '');
              if (cleanNumber.length != 16) {
                return 'Card number must be 16 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Cardholder Name
          _buildTextField(
            controller: _cardHolderController,
            label: 'Cardholder Name',
            hint: 'John Doe',
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Cardholder name is required';
              }
              if (value!.split(' ').length < 2) {
                return 'Please enter first and last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Expiry and CVV Row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _expiryController,
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final digits = newValue.text.replaceAll(
                        RegExp(r'\D'),
                        '',
                      );
                      final limited = digits.length > 4
                          ? digits.substring(0, 4)
                          : digits;
                      final deleting =
                          newValue.text.length < oldValue.text.length;
                      final addSlash =
                          limited.length > 2 ||
                          (limited.length == 2 && !deleting);
                      final text = addSlash
                          ? '${limited.substring(0, 2)}/${limited.substring(2)}'
                          : limited;
                      final cursor = newValue.selection.extentOffset.clamp(
                        0,
                        newValue.text.length,
                      );
                      final digitsBeforeCursor = newValue.text
                          .substring(0, cursor)
                          .replaceAll(RegExp(r'\D'), '')
                          .length;
                      final offset =
                          digitsBeforeCursor +
                          (addSlash && digitsBeforeCursor >= 2 ? 1 : 0);
                      return TextEditingValue(
                        text: text,
                        selection: TextSelection.collapsed(
                          offset: offset.clamp(0, text.length),
                        ),
                      );
                    }),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Expiry date is required';
                    }
                    if (!RegExp(
                      r'^(0[1-9]|1[0-2])/[0-9]{2}$',
                    ).hasMatch(value!)) {
                      return 'Use MM/YY format';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cvvController,
                  label: 'CVV',
                  hint: '123',
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'CVV is required';
                    }
                    if (value!.length != 3) {
                      return 'CVV must be 3 digits';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Save Card Checkbox
          Row(
            children: [
              Checkbox(
                value: _saveCard,
                onChanged: (value) {
                  setState(() => _saveCard = value ?? false);
                },
                fillColor: WidgetStateProperty.all(shopGold),
              ),
              const Expanded(
                child: Text(
                  'Save this card for future purchases',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'serif',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Add Card Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pushNamed(
                    context,
                    '/payment_summary',
                    arguments: {
                      'method': 'card',
                      'saveCard': _saveCard,
                      'cardNumber': _cardNumberController.text,
                      'cardHolder': _cardHolderController.text,
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: shopGold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Card',
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

  Widget _buildCardPreview() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF563A29), Color(0xFF7B4F30)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: shopGold.withValues(alpha: 0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'CREDIT CARD',
                style: TextStyle(
                  color: shopCream,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Icon(Icons.credit_card, color: shopGold, size: 30),
          ],
        ),
        const SizedBox(height: 24),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _maskCardNumber(
              _cardNumberController.text.isEmpty
                  ? '0000 0000 0000 0000'
                  : _cardNumberController.text,
            ),
            style: const TextStyle(
              color: shopCream,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARDHOLDER',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _cardHolderController.text.isEmpty
                        ? 'YOUR NAME'
                        : _cardHolderController.text.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: shopCream,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'EXPIRES',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                const SizedBox(height: 6),
                Text(
                  _expiryController.text.isEmpty
                      ? 'MM/YY'
                      : _expiryController.text,
                  style: const TextStyle(
                    color: shopCream,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        color: shopCream,
        fontSize: 14,
        fontFamily: 'serif',
      ),
      inputFormatters:
          inputFormatters ??
          (keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : []),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontFamily: 'serif',
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontFamily: 'serif',
        ),
        filled: true,
        fillColor: shopBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: shopCream.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: shopGold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        counterText: '',
      ),
    );
  }
}
