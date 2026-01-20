import 'package:flutter/material.dart';
import 'otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUpComplete() {
    // Navigate directly to OTP screen without popup
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OtpVerificationScreen()),
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),

                    const Text(
                      "Create an account",
                      style: TextStyle(
                        fontSize: 24, // Smaller font
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
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

                    Text(
                      "Welcome to Cafe Chocolate please login your account.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12, // Smaller font
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30), // Reduced spacing

                    _buildTextField(
                      controller: _firstNameController,
                      label: "First Name",
                      hint: "first name",
                      keyboardType: TextInputType.name,
                    ),

                    const SizedBox(height: 16), // Reduced spacing

                    _buildTextField(
                      controller: _lastNameController,
                      label: "Last Name",
                      hint: "Last name",
                      keyboardType: TextInputType.name,
                    ),

                    const SizedBox(height: 16), // Reduced spacing

                    _buildTextField(
                      controller: _emailController,
                      label: "Email Address",
                      hint: "to send your confirmation",
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16), // Reduced spacing

                    _buildTextField(
                      controller: _mobileController,
                      label: "Mobile Number",
                      hint: "so we can contact you",
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16), // Reduced spacing
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Your Password",
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: "password",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFC107),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, // Reduced padding
                          horizontal: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 30), // Reduced spacing
                    // Sign Up Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _onSignUpComplete();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
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
                        "Sign up here",
                        style: TextStyle(
                          fontSize: 14, // Smaller font
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          fontFamily: 'Roboto', // Changed font
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'Roboto',
      ), // Added font and size
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontFamily: 'Roboto',
        ), // Smaller label
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontFamily: 'Roboto',
        ), // Smaller hint
        filled: true,
        fillColor: Colors.white.withOpacity(0.18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Smaller border radius
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12, // Reduced padding
          horizontal: 16,
        ),
      ),
    );
  }
}
