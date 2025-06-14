import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/recipes/presentation/screens/recipes_screen.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isFavorite = false;
  int selectedServings = 4;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.recipe.isFavorite;
    selectedServings =
        int.tryParse(widget.recipe.servings.split(' ').first) ?? 4;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _adjustServings(int change) {
    setState(() {
      selectedServings = (selectedServings + change).clamp(1, 12);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x00E5E7EB), AppTheme.secondaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.5, 1.0],
            ),
            border: Border(
              bottom: BorderSide(color: AppTheme.borderColor, width: 0.8),
            ),
          ),
          child: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            automaticallyImplyLeading: false,
            title: Text(
              'Eatsoon',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryColor,
                fontSize: 26,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              GestureDetector(
                onTap: () {
                  // Navigate to profile tab (index 4) using AppShell navigation
                  final shellState = AppShell.shellKey.currentState;
                  if (shellState != null) {
                    shellState.navigateToTab(4); // Profile tab is at index 4
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: AppTheme.whiteColor,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/settings_icon.svg',
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.secondaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [_buildHeroImage(), _buildRecipeContent()]),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Recipe Image
          ClipRRect(
            child: Image.network(
              widget.recipe.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          // Favorite button
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? const Color(0xFFEF4444) : Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          // Recipe title and category
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.recipe.categoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.recipe.category,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.recipe.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.recipe.description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecipeStats(),
          const SizedBox(height: 32),
          _buildIngredientsSection(),
          const SizedBox(height: 32),
          _buildInstructionsSection(),
          const SizedBox(height: 32),
          _buildNutritionSection(),
          const SizedBox(height: 100), // Space for bottom actions
        ],
      ),
    );
  }

  Widget _buildRecipeStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.4,
            offset: const Offset(0, 1.2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.access_time_rounded,
              'Cook Time',
              widget.recipe.cookTime,
            ),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _buildStatItem(
              Icons.check_circle_rounded,
              'Difficulty',
              widget.recipe.difficulty,
            ),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.people_rounded,
                  size: 20,
                  color: widget.recipe.categoryColor,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Servings',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _adjustServings(-1),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedServings.toString(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF111827),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _adjustServings(1),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: widget.recipe.categoryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Color(0xFF6B7280),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF111827),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    final ingredients = _getDummyIngredients();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ingredients',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF111827),
                height: 1.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.recipe.ingredientColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${ingredients.length} items',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: widget.recipe.ingredientTextColor,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2.4,
                offset: const Offset(0, 1.2),
              ),
            ],
          ),
          child: Column(
            children:
                ingredients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  final isLast = index == ingredients.length - 1;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border:
                          isLast
                              ? null
                              : const Border(
                                bottom: BorderSide(
                                  color: Color(0xFFF3F4F6),
                                  width: 1,
                                ),
                              ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ingredient['color'],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              ingredient['emoji'],
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredient['name'],
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFF111827),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ingredient['amount'],
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (ingredient['inInventory'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'In Stock',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: Color(0xFF065F46),
                                height: 1.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsSection() {
    final instructions = _getDummyInstructions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF111827),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children:
              instructions.asMap().entries.map((entry) {
                final index = entry.key;
                final instruction = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2.4,
                        offset: const Offset(0, 1.2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: widget.recipe.categoryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              instruction['title'],
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFF111827),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              instruction['description'],
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                height: 1.4,
                              ),
                            ),
                            if (instruction['time'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: widget.recipe.categoryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    instruction['time'],
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: widget.recipe.categoryColor,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildNutritionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutrition (per serving)',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF111827),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2.4,
                offset: const Offset(0, 1.2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNutritionItem('Calories', '320', 'kcal'),
                  _buildNutritionItem('Protein', '12g', '24%'),
                  _buildNutritionItem('Carbs', '45g', '15%'),
                  _buildNutritionItem('Fat', '8g', '12%'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionItem(String label, String value, String percentage) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF111827),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Color(0xFF6B7280),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          percentage,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 10,
            color: widget.recipe.categoryColor,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to shopping list!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined, size: 20),
              label: const Text('Add to Cart'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Starting cooking mode...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Start Cooking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyIngredients() {
    // Generate ingredients based on recipe type
    switch (widget.recipe.id) {
      case '1': // Banana Bread
        return [
          {
            'name': 'Ripe Bananas',
            'amount': '3 large',
            'emoji': '🍌',
            'color': const Color(0xFFFEF3C7),
            'inInventory': true,
          },
          {
            'name': 'All-purpose Flour',
            'amount': '2 cups',
            'emoji': '🌾',
            'color': const Color(0xFFF3F4F6),
            'inInventory': false,
          },
          {
            'name': 'Sugar',
            'amount': '3/4 cup',
            'emoji': '🍯',
            'color': const Color(0xFFFEF3C7),
            'inInventory': true,
          },
          {
            'name': 'Butter',
            'amount': '1/3 cup',
            'emoji': '🧈',
            'color': const Color(0xFFFEF3C7),
            'inInventory': false,
          },
          {
            'name': 'Eggs',
            'amount': '2 large',
            'emoji': '🥚',
            'color': const Color(0xFFFEF3C7),
            'inInventory': true,
          },
          {
            'name': 'Baking Soda',
            'amount': '1 tsp',
            'emoji': '🥄',
            'color': const Color(0xFFF3F4F6),
            'inInventory': false,
          },
        ];
      case '2': // Cherry Smoothie Bowl
        return [
          {
            'name': 'Frozen Cherries',
            'amount': '1 cup',
            'emoji': '🍒',
            'color': const Color(0xFFFEE2E2),
            'inInventory': true,
          },
          {
            'name': 'Greek Yogurt',
            'amount': '1/2 cup',
            'emoji': '🥛',
            'color': const Color(0xFFDDEAFE),
            'inInventory': true,
          },
          {
            'name': 'Banana',
            'amount': '1 medium',
            'emoji': '🍌',
            'color': const Color(0xFFFEF3C7),
            'inInventory': false,
          },
          {
            'name': 'Granola',
            'amount': '1/4 cup',
            'emoji': '🌾',
            'color': const Color(0xFFF3F4F6),
            'inInventory': true,
          },
          {
            'name': 'Honey',
            'amount': '1 tbsp',
            'emoji': '🍯',
            'color': const Color(0xFFFEF3C7),
            'inInventory': false,
          },
        ];
      default:
        return [
          {
            'name': widget.recipe.primaryIngredient.substring(2),
            'amount': '2 cups',
            'emoji': widget.recipe.primaryIngredient.substring(0, 2),
            'color': widget.recipe.ingredientColor,
            'inInventory': true,
          },
          {
            'name': 'Olive Oil',
            'amount': '2 tbsp',
            'emoji': '🫒',
            'color': const Color(0xFFD1FAE5),
            'inInventory': false,
          },
          {
            'name': 'Salt',
            'amount': '1 tsp',
            'emoji': '🧂',
            'color': const Color(0xFFF3F4F6),
            'inInventory': true,
          },
          {
            'name': 'Black Pepper',
            'amount': '1/2 tsp',
            'emoji': '🌶️',
            'color': const Color(0xFFFEE2E2),
            'inInventory': false,
          },
          {
            'name': 'Garlic',
            'amount': '2 cloves',
            'emoji': '🧄',
            'color': const Color(0xFFF3F4F6),
            'inInventory': true,
          },
        ];
    }
  }

  List<Map<String, dynamic>> _getDummyInstructions() {
    // Generate instructions based on recipe type
    switch (widget.recipe.id) {
      case '1': // Banana Bread
        return [
          {
            'title': 'Preheat and Prepare',
            'description':
                'Preheat your oven to 350°F (175°C). Grease a 9x5 inch loaf pan with butter or cooking spray.',
            'time': '5 min',
          },
          {
            'title': 'Mash Bananas',
            'description':
                'In a large bowl, mash the ripe bananas with a fork until smooth. A few small lumps are okay.',
            'time': '3 min',
          },
          {
            'title': 'Mix Wet Ingredients',
            'description':
                'Add melted butter, sugar, beaten eggs, and vanilla extract to the mashed bananas. Mix well.',
            'time': '5 min',
          },
          {
            'title': 'Combine Dry Ingredients',
            'description':
                'In a separate bowl, whisk together flour, baking soda, and salt.',
            'time': '2 min',
          },
          {
            'title': 'Combine and Bake',
            'description':
                'Gradually fold the dry ingredients into the wet ingredients until just combined. Pour into prepared pan and bake.',
            'time': '60 min',
          },
          {
            'title': 'Cool and Serve',
            'description':
                'Let cool in pan for 10 minutes, then turn out onto a wire rack. Cool completely before slicing.',
            'time': '15 min',
          },
        ];
      case '2': // Cherry Smoothie Bowl
        return [
          {
            'title': 'Prepare Ingredients',
            'description':
                'Take frozen cherries out of freezer 5 minutes before blending to soften slightly.',
            'time': '5 min',
          },
          {
            'title': 'Blend Base',
            'description':
                'In a high-speed blender, combine frozen cherries, Greek yogurt, banana, and honey. Blend until smooth and thick.',
            'time': '2 min',
          },
          {
            'title': 'Adjust Consistency',
            'description':
                'If too thick, add a splash of milk. If too thin, add more frozen fruit. Blend again briefly.',
            'time': '1 min',
          },
          {
            'title': 'Serve and Top',
            'description':
                'Pour into a bowl and top with granola, fresh berries, and a drizzle of honey. Serve immediately.',
            'time': '2 min',
          },
        ];
      default:
        return [
          {
            'title': 'Prepare Ingredients',
            'description':
                'Wash and chop all vegetables. Measure out spices and seasonings.',
            'time': '10 min',
          },
          {
            'title': 'Heat Pan',
            'description':
                'Heat olive oil in a large pan or skillet over medium-high heat.',
            'time': '2 min',
          },
          {
            'title': 'Cook Main Ingredient',
            'description':
                'Add the main ingredient to the pan and cook according to recipe requirements.',
            'time': '8 min',
          },
          {
            'title': 'Season and Finish',
            'description':
                'Add seasonings and any remaining ingredients. Cook until everything is heated through.',
            'time': '5 min',
          },
          {
            'title': 'Serve',
            'description': 'Remove from heat and serve immediately while hot.',
            'time': null,
          },
        ];
    }
  }
}
