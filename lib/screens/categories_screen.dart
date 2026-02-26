import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fav_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        const Text(
                          'Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildCategoryCard(context, 'Cake', '/cake'),
                    const SizedBox(height: 16),
                    _buildCategoryCard(context, 'Brownies', '/brownies'),
                    const SizedBox(height: 16),
                    _buildCategoryCard(context, 'Cookies', '/cookies'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String route) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(49, 0, 0, 0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromARGB(159, 245, 157, 74)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'serif',
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, route),
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Color.fromARGB(159, 245, 157, 74),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
