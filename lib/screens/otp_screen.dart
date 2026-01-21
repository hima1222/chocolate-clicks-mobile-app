import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chocolate_clicks/screens/home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});
  }

  void _onOtpVerified() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Up Complete'),
          content: Text('Your account has been created successfully.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/welcome_profile');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/cafe_background.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.52)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 325,
                    ), // Add space to push content lower
                    // Main title
                    const Text(
                      "Verify Your Account",
                      style: TextStyle(
                        fontSize: 24, // Smaller font
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.6,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(1.5, 1.5),
                            blurRadius: 5,
                          ),
                        ],
                        fontFamily: 'Roboto', // Changed font
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "OTP Verification",
                      style: TextStyle(
                        fontSize: 16, // Smaller font
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "OTP has sent to you mobile number",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12, // Smaller font
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30), // Reduced spacing
                    // OTP boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 40, // Smaller width
                          height: 48, // Smaller height
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ), // Smaller margin
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // Smaller border radius
                            border: Border.all(
                              color: _controllers[index].text.isNotEmpty
                                  ? const Color(0xFFFFC107)
                                  : Colors.transparent,
                              width: 1.8,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 20, // Smaller font
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) => _onChanged(value, index),
                            onTapOutside: (_) =>
                                FocusScope.of(context).unfocus(),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 30), // Reduced spacing
                    // Submit button
                    ElevatedButton(
                      onPressed: _otp.length == 6
                          ? () {
                              _onOtpVerified();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFFE65100,
                        ).withOpacity(0.45),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ), // Reduced padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Smaller border radius
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 14, // Smaller font
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Reduced spacing
                    // Optional: Resend link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: resend OTP logic
                        },
                        child: const Text(
                          "Didn't receive OTP? Resend",
                          style: TextStyle(
                            color: Color(0xFFFFC107),
                            fontSize: 12, // Smaller font
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40), // Add space at bottom
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}