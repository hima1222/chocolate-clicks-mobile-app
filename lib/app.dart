import 'package:flutter/material.dart';
import 'features/onboarding/screens/landing.dart';
import 'features/home/screens/home_screen.dart';

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
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}