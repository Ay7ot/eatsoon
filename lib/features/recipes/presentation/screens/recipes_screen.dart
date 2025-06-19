import 'package:eat_soon/features/inventory/data/services/inventory_service.dart';
import 'package:eat_soon/features/recipes/data/models/recipe_model.dart';
import 'package:eat_soon/features/recipes/data/services/recipe_service.dart';
import 'package:eat_soon/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:eat_soon/features/home/models/food_item.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with AutomaticKeepAliveClientMixin {
  final RecipeService _recipeService = RecipeService();
  final InventoryService _inventoryService = InventoryService();

  late Future<List<Recipe>> _recipeFuture;
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isUsingFallback = false;
  StreamSubscription? _inventorySubscription;
  Timer? _debounce;
  bool _isInitialLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _fetchRecipes();
    _searchController.addListener(_applySearch);
    _inventorySubscription = _inventoryService.getFoodItemsStream().listen((_) {
      if (_isInitialLoad) {
        _isInitialLoad = false;
        return;
      }
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _recipeFuture = _fetchRecipes();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _inventorySubscription?.cancel();
    _debounce?.cancel();
    _searchController.removeListener(_applySearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Recipe>> _fetchRecipes() async {
    // First try to get items that are expiring soon from the user's pantry
    final expiringItems = await _inventoryService.getExpiringSoonItems(days: 5);

    // Convert the item list to ingredient names understood by Spoonacular
    List<String> ingredients = expiringItems.map((e) => e.name).toList();

    // Fallback: if the user has no expiring items yet, query with some common pantry staples.
    if (ingredients.isEmpty) {
      _isUsingFallback = true;
      ingredients = [
        'Eggs',
        'Milk',
        'Bread',
        'Tomato',
        'Onion',
        'Garlic',
        'Chicken',
      ];
    } else {
      _isUsingFallback = false;
    }

    final recipes = await _recipeService.getRecipesByIngredients(
      ingredients,
      limit: _isUsingFallback ? 10 : 20,
    );
    if (recipes.isEmpty) {
      _allRecipes = [];
      _filteredRecipes = [];
      return [];
    }

    // Create a map of recipeId to the original recipe for easy lookup
    final ingredientInfoMap = {for (var r in recipes) r.id: r};

    // Get the detailed information for the recipes found
    final recipeIds = recipes.map((r) => r.id).toList();
    final detailedRecipes = await _recipeService.getRecipesInformationBulk(
      recipeIds,
    );

    // Combine detailed info with the original ingredient counts
    final finalRecipes =
        detailedRecipes.map((detailedRecipe) {
          final originalRecipe = ingredientInfoMap[detailedRecipe.id];
          if (originalRecipe != null) {
            return detailedRecipe.copyWith(
              usedIngredientCount: originalRecipe.usedIngredientCount,
              missedIngredientCount: originalRecipe.missedIngredientCount,
            );
          }
          return detailedRecipe;
        }).toList();

    _allRecipes = finalRecipes;
    _filteredRecipes = finalRecipes;
    return finalRecipes;
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecipes =
          _allRecipes
              .where((r) => r.title.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(title: 'Eatsoon'),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_isUsingFallback) _buildFallbackNotice(),
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _recipeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSkeleton();
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (_filteredRecipes.isEmpty) {
                  return const Center(child: Text('No recipes found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _filteredRecipes[index];
                    return _buildRecipeCard(recipe);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.4),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search recipes...',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7DD3FC)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF0C4A6E)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No expiring items found. Showing some easy recipe ideas to get you started!',
              style: TextStyle(
                color: Color(0xFF0C4A6E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: recipe.categoryColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildCardImage(recipe), _buildCardDetails(recipe)],
        ),
      ),
    );
  }

  Widget _buildCardImage(Recipe recipe) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          Image.network(
            recipe.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.grey,
                    size: 50,
                  ),
                ),
          ),
          // Gradient overlay for text visibility
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
          // Category Tag
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: recipe.categoryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                recipe.category.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Title
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Text(
              recipe.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4.0, color: Colors.black54)],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                Icons.timer_outlined,
                recipe.cookTime,
                'Cook Time',
              ),
              _buildStatItem(
                Icons.people_alt_outlined,
                recipe.servings,
                'Servings',
              ),
              _buildStatItem(
                Icons.star_border_rounded,
                recipe.difficulty,
                'Difficulty',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!_isUsingFallback && recipe.usedIngredientCount > 0)
                _buildIngredientChip(
                  '${recipe.usedIngredientCount} Used',
                  Colors.green.shade100,
                  Colors.green.shade800,
                ),
              if (!_isUsingFallback && recipe.missedIngredientCount > 0)
                _buildIngredientChip(
                  '${recipe.missedIngredientCount} Missing',
                  Colors.red.shade100,
                  Colors.red.shade800,
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: recipe.categoryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'View Recipe',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientChip(String label, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder:
            (_, __) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
      ),
    );
  }
}
