import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fav_background.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Overlay
          Container(color: Colors.black.withValues(alpha: 0.3)),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button and title
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Form container with transparent background
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Edit Your Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Profile edit form
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter your full name',
                              labelStyle: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email address',
                              labelStyle: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'Enter your phone number',
                              labelStyle: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Address',
                              hintText: 'Enter your address',
                              labelStyle: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.95),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Card Info',
                              hintText: 'Enter your card information',
                              labelStyle: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.95),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                // Save profile logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile information saved'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'serif',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
