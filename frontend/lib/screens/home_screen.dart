import 'package:chocolate_clicks/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pre-login welcome screen. Same routes as before: /login and /register.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _bg = Color(0xFF1A1410);
  static const _cream = Color(0xFFF6E6D7);
  static const _accent = Color(0xFFE8B07A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: AppImage.asset(
              'assets/images/welcome_latte.jpeg', // your latte photo
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.3, 0.62, 1],
                  colors: [
                    _bg.withValues(alpha: 0.45),
                    _bg.withValues(alpha: 0.1),
                    _bg.withValues(alpha: 0.85),
                    _bg,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    'CAFE CHOCOLATE  ·  COLOMBO',
                    style: GoogleFonts.inter(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome to\nChocolate Clicks',
                    style: GoogleFonts.fraunces(
                      color: _cream,
                      fontSize: 40,
                      height: 1.05,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Cakes, brownies and cookies, plus workshops worth '
                    'showing up for. Log in or sign up to explore.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFE3D2C2),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/login'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _cream,
                        foregroundColor: _bg,
                        shape: const StadiumBorder(),
                        textStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Log in'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/register'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _cream,
                        side: BorderSide(color: _cream.withValues(alpha: 0.5)),
                        shape: const StadiumBorder(),
                        textStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Sign up'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}