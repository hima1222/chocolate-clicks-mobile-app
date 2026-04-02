import 'package:flutter/material.dart';
import 'package:chocolate_clicks/services/auth_service.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _loading = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _auth = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final resp = await _auth.login(
        emailOrUsername: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (resp.success) {
        Navigator.pushReplacementNamed(context, '/welcome_profile');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(resp.message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
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
            child: Container(color: Colors.black.withValues(alpha: 0.52)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(
                    flex: 12,
                  ), // Increased spacer to push content lower

                  const Text(
                    "Cafe Chocolate",
                    style: TextStyle(
                      fontSize: 32, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          offset: Offset(2, 2),
                          blurRadius: 6,
                        ),
                      ],
                      fontFamily: 'kalnia', // Changed font
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Welcome back! Please login to your account",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14, // Reduced font size
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2), // Reduced spacer

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.92),
                            hintText: "Username / Mobile Number / Email",
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              size: 20,
                            ), // Smaller icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // Smaller border radius
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, // Reduced padding
                              horizontal: 16,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16), // Reduced spacing

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.92),
                            hintText: "Password",
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Forgot password screen / bottom sheet
                            },
                            child: const Text(
                              "Forgot your password?",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Login Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              159,
                              243,
                              102,
                              27,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Sign Up row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?  ",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          "Sign up here",
                          style: TextStyle(
                            color: Color(0xFFFFC107),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
