import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:eat_soon/features/recipes/data/models/recipe_model.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eat_soon/features/home/services/activity_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final ActivityService _activityService = ActivityService();
  bool isFavorite = false;
  int selectedServings = 4;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.recipe.isFavorite;
    selectedServings =
        int.tryParse(widget.recipe.servings.split(' ').first) ?? 4;

    // Log that the recipe was viewed
    _logRecipeViewed();
  }

  void _logRecipeViewed() {
    _activityService.logRecipeViewed(
      widget.recipe.title,
      widget.recipe.imageUrl,
    );
  }

  void _adjustServings(int change) {
    setState(() {
      selectedServings = (selectedServings + change).clamp(1, 12);
    });
  }

  // Helper to translate recipe category names
  String _translateCategory(String category) {
    final key = 'recipe_cat_${category.toLowerCase().replaceAll(' ', '_')}';
    final translated = key.tr;
    return translated == key ? category : translated;
  }

  // Helper to translate difficulty values (Easy/Medium/Hard)
  String _translateDifficulty(String difficulty) {
    final map = {
      'easy': 'recipes_diff_easy',
      'medium': 'recipes_diff_medium',
      'hard': 'recipes_diff_hard',
    };
    final key = map[difficulty.toLowerCase()];
    if (key == null) return difficulty;
    final translated = key.tr;
    return translated == key ? difficulty : translated;
  }

  // Fallback emojis for different ingredient categories
  String _getEmojiForIngredient(String ingredient) {
    final name = ingredient.toLowerCase();

    if (name.contains('dairy') ||
        name.contains('milk') ||
        name.contains('cheese') ||
        name.contains('yogurt'))
      return '🥛';
    if (name.contains('fruit') ||
        name.contains('apple') ||
        name.contains('banana') ||
        name.contains('orange') ||
        name.contains('berry'))
      return '🍎';
    if (name.contains('vegetable') ||
        name.contains('lettuce') ||
        name.contains('spinach') ||
        name.contains('carrot') ||
        name.contains('tomato') ||
        name.contains('onion') ||
        name.contains('garlic'))
      return '🥬';
    if (name.contains('meat') ||
        name.contains('chicken') ||
        name.contains('beef') ||
        name.contains('pork'))
      return '🍗';
    if (name.contains('bakery') ||
        name.contains('bread') ||
        name.contains('baked') ||
        name.contains('flour'))
      return '🍞';
    if (name.contains('pantry') ||
        name.contains('pasta') ||
        name.contains('rice') ||
        name.contains('cereal') ||
        name.contains('sauce'))
      return '🥫';
    if (name.contains('beverage') ||
        name.contains('drink') ||
        name.contains('juice'))
      return '🥤';
    if (name.contains('snack') ||
        name.contains('chip') ||
        name.contains('cookie'))
      return '🍪';
    if (name.contains('frozen')) return '🧊';
    if (name.contains('oil') || name.contains('vinegar')) return '🫒';
    if (name.contains('sugar') ||
        name.contains('honey') ||
        name.contains('syrup'))
      return '🍯';
    if (name.contains('butter')) return '🧈';
    if (name.contains('egg')) return '🥚';
    if (name.contains('spice') ||
        name.contains('herb') ||
        name.contains('salt') ||
        name.contains('pepper'))
      return '🧂';

    return '🥣'; // Default fallback
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
              'Eatsooon',
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
      body: Column(
        children: [
          // Sub-header for recipe context
          _buildSubHeader(),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildHeroImage(), _buildRecipeContent()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF4B5563),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipe.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _translateCategory(widget.recipe.category),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.recipe.imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) =>
                    const Center(child: Icon(Icons.image_not_supported)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                ],
                stops: const [0.6, 0.8, 1.0],
              ),
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
          _buildMetaInfo(),
          const SizedBox(height: 24),
          _buildSectionTitle('recipe_detail_description'.tr),
          const SizedBox(height: 8),
          Text(
            widget.recipe.description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildIngredientsSection(),
          const SizedBox(height: 24),
          _buildInstructionsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMetaInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              'recipe_detail_cook_time'.tr,
              widget.recipe.cookTime,
              Icons.timer_outlined,
              Colors.orange,
            ),
            const VerticalDivider(width: 1),
            _buildStatItem(
              'recipe_detail_difficulty'.tr,
              _translateDifficulty(widget.recipe.difficulty),
              Icons.star_border_rounded,
              Colors.amber,
            ),
            const VerticalDivider(width: 1),
            _buildServingsChanger(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildServingsChanger() {
    return Column(
      children: [
        const Icon(
          Icons.people_alt_outlined,
          color: Colors.lightBlue,
          size: 28,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _adjustServings(-1),
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.grey,
            ),
            Text(
              '$selectedServings',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            IconButton(
              onPressed: () => _adjustServings(1),
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.grey,
            ),
          ],
        ),
        Text(
          'recipe_detail_servings'.tr,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    final ingredients = widget.recipe.ingredients;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('recipe_detail_ingredients'.tr),
        const SizedBox(height: 16),
        ...ingredients.map(
          (ing) => _buildIngredientItem(
            ing['name']!,
            ing['amount']!,
            _getEmojiForIngredient(ing['name']!),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(String name, String amount, String emoji) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection() {
    final instructions = widget.recipe.instructions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('recipe_detail_instructions'.tr),
        const SizedBox(height: 16),
        if (instructions.isEmpty) Text('recipe_detail_no_instructions'.tr),
        ...instructions.asMap().entries.map(
          (e) => _buildInstructionItem(e.key + 1, e.value),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppTheme.secondaryColor,
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Color(0xFF111827),
      ),
    );
  }
}
