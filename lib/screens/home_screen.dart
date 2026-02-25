import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chocolate Clicks'),
        backgroundColor: Colors.brown[800],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Show all images stacked
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/home1.jpg',
                      fit: BoxFit.cover,
                      height: isSmallScreen ? 150 : 200,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/home2.jpg',
                      fit: BoxFit.cover,
                      height: isSmallScreen ? 150 : 200,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/home3.jpg',
                      fit: BoxFit.cover,
                      height: isSmallScreen ? 150 : 200,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Welcome text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Welcome to Chocolate Clicks',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.brown[900],
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Indulge in the finest chocolate treats. Sign up or log in to explore our delicious collection.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.brown[700],
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/register');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.brown[700]!),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.brown[700], fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    );
  }
}

