import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All', 'New', 'Popular', 'Seasonal'];
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Cakes',
      'count': 24,
      'route': '/cake',
      'color': const Color(0xFF8B2D2D),
      'icon': Icons.cake,
    },
    {
      'title': 'Brownies',
      'count': 12,
      'route': '/brownies',
      'color': const Color(0xFF643C1F),
      'icon': Icons.square_foot,
    },
    {
      'title': 'Cookies',
      'count': 18,
      'route': '/cookies',
      'color': const Color(0xFF4E2C39),
      'icon': Icons.cookie,
    },
    {
      'title': 'Cupcakes',
      'count': 9,
      'route': '/cake',
      'color': const Color(0xFF7C4865),
      'icon': Icons.emoji_food_beverage,
    },
    {
      'title': 'Chocolates',
      'count': 31,
      'route': '/cake',
      'color': const Color(0xFF5A3027),
      'icon': Icons.icecream,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = _categories.where((category) {
      final title = (category['title'] as String).toLowerCase();
      return title.contains(query) || query.isEmpty;
    }).toList();

    final heroCategory = filtered.firstWhere(
      (category) => category['title'] == 'Cakes',
      orElse: () => filtered.isNotEmpty ? filtered.first : _categories.first,
    );
    final otherCategories = filtered.where((category) => category != heroCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF120101),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF260B0B),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white70),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search treats...',
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final selected = index == _selectedFilterIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(_filters[index]),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        },
                        selectedColor: const Color(0xFFB33A3A),
                        backgroundColor: const Color(0xFF260B0B),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                        ),
                        side: const BorderSide(color: Colors.transparent),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 22),
              _buildHeroCard(context, heroCategory),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: otherCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final item = otherCategories[index];
                  return _buildCategoryTile(context, item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, category['route'] as String),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [category['color'] as Color, const Color(0xFF120101)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category['icon'] as IconData, color: Colors.white, size: 32),
                const SizedBox(width: 14),
                Text(
                  category['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '${category['count']} varieties',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 20),
            const Text(
              'Flagship category with trending sweets and signature cakes.',
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, category['route'] as String),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F0A0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (category['color'] as Color).withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(category['icon'] as IconData, color: Colors.white, size: 26),
            ),
            const Spacer(),
            Text(
              category['title'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${category['count']} items',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
