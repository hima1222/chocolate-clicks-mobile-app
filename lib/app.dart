import 'package:flutter/material.dart';
import 'screens/landing.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_profile.dart';
import 'screens/cake_items_screen.dart';
import 'screens/brownies_items_screen.dart';
import 'screens/cookies_items_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chocolate Clicks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      
      home: const LandingScreen(),
      routes: {
        '/landing': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const SignUpScreen(),
        '/otp': (context) => const OtpVerificationScreen(),
        '/welcome_profile': (context) => const WelcomeProfileScreen(),
        '/home': (context) => const HomeScreen(),
        '/cake': (context) => const CakeItemsScreen(),
        '/brownies': (context) => const BrowniesItemsScreen(),
        '/cookies': (context) => const CookiesItemsScreen(),
      },
    );
  }
}