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

import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/upcoming_events_screen.dart';
import 'screens/events_screen.dart';
import 'screens/mask_painting_workshop_screen.dart';
import 'screens/tasting_luxe_screen.dart';
import 'screens/bake_it_happen_screen.dart';
import 'screens/summer_cake_picnics_screen.dart';
import 'screens/cake_dates_screen.dart';

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
        '/profile': (context) => const ProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/favourites': (context) => const FavouritesScreen(),
        '/upcoming_events': (context) => const UpcomingEventsScreen(),
        '/events': (context) => const EventsScreen(),
        '/mask_painting_workshop': (context) =>
            const MaskPaintingWorkshopScreen(),
        '/tasting_luxe': (context) => const TastingLuxeScreen(),
        '/bake_it_happen': (context) => const BakeItHappenScreen(),
        '/summer_cake_picnics': (context) => const SummerCakePicnicsScreen(),
        '/cake_dates': (context) => const CakeDatesScreen(),
        '/cake': (context) => const CakeItemsScreen(),
        '/brownies': (context) => const BrowniesItemsScreen(),
        '/cookies': (context) => const CookiesItemsScreen(),
      },
    );
  }
}

