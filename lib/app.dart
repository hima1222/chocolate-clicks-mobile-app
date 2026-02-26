import 'package:flutter/material.dart';
import 'screens/landing.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_profile.dart';
import 'screens/categories_screen.dart';
import 'screens/events_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/upcoming_events_screen.dart';
import 'screens/payment_info_screen.dart';
import 'screens/mask_painting_workshop_screen.dart';
import 'screens/tasting_luxe_screen.dart';
import 'screens/bake_it_happen_screen.dart';
import 'screens/summer_cake_picnics_screen.dart';
import 'screens/cake_dates_screen.dart';
import 'screens/cake_items_screen.dart';
import 'screens/brownies_items_screen.dart';
import 'screens/cookies_items_screen.dart';
import 'screens/payment_method_screen.dart';
import 'screens/add_card_screen.dart';
import 'screens/digital_wallet_screen.dart';
import 'screens/bank_transfer_screen.dart';
import 'screens/upi_payment_screen.dart';
import 'screens/payment_summary_screen.dart';
import 'screens/payment_success_screen.dart';
import 'screens/payment_failure_screen.dart';

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
        '/categories': (context) => const CategoriesScreen(),
        '/events': (context) => const EventsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/favourites': (context) => const FavouritesScreen(),
        '/upcoming_events': (context) => const UpcomingEventsScreen(),
        '/cart': (context) => const CartScreen(),
        '/payment_info': (context) => const PaymentInfoScreen(),
        '/mask_painting_workshop': (context) =>
            const MaskPaintingWorkshopScreen(),
        '/tasting_luxe': (context) => const TastingLuxeScreen(),
        '/bake_it_happen': (context) => const BakeItHappenScreen(),
        '/summer_cake_picnics': (context) => const SummerCakePicnicsScreen(),
        '/cake_dates': (context) => const CakeDatesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
        '/cake': (context) => const CakeItemsScreen(),
        '/brownies': (context) => const BrowniesItemsScreen(),
        '/cookies': (context) => const CookiesItemsScreen(),
        '/payment_method': (context) => const PaymentMethodScreen(),
        '/add_card': (context) => const AddCardScreen(),
        '/digital_wallet': (context) => const DigitalWalletScreen(),
        '/bank_transfer': (context) => const BankTransferScreen(),
        '/upi_payment': (context) => const UPIPaymentScreen(),
        '/payment_summary': (context) => const PaymentSummaryScreen(),
        '/payment_success': (context) => const PaymentSuccessScreen(),
        '/payment_failure': (context) => const PaymentFailureScreen(),
      },
    );
  }
}
