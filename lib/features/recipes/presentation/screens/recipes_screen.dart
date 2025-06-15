import 'package:flutter/material.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'dart:async';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with AutomaticKeepAliveClientMixin {
  String selectedCategory = 'Use Soon';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool showFavoritesOnly = false;
  Set<String> selectedDifficulties = {};
  Set<String> selectedCookTimes = {};
  int displayedRecipesCount = 6;
  bool isLoadingMore = false;
  Timer? _debounceTimer;

  // Cache filtered results to avoid recomputation
  List<Recipe>? _cachedFilteredRecipes;
  String? _lastFilterKey;

  // Keep state alive to prevent rebuilding when switching tabs
  @override
  bool get wantKeepAlive => true;

  // Dummy recipe data with images
  final List<Recipe> allRecipes = [
    Recipe(
      id: '1',
      title: 'Banana Bread',
      description: 'Perfect for overripe bananas. Moist and delicious!',
      imageUrl:
          'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=300&fit=crop',
      cookTime: '60 min',
      difficulty: 'Easy',
      servings: '6 servings',
      category: 'Use Today',
      categoryColor: const Color(0xFFEF4444),
      primaryIngredient: '🍌 Bananas',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+3 more',
      isFavorite: false,
      borderColor: const Color(0xFFEF4444),
      tags: ['baking', 'dessert', 'banana'],
    ),
    Recipe(
      id: '2',
      title: 'Quick Veggie Stir Fry',
      description: 'Use up those vegetables before they go bad!',
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&h=300&fit=crop',
      cookTime: '12 min',
      difficulty: 'Easy',
      servings: '2 servings',
      category: 'Quick',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🥕 Mixed Vegetables',
      ingredientColor: const Color(0xFFD1FAE5),
      ingredientTextColor: const Color(0xFF065F46),
      additionalIngredients: '+4 more',
      isFavorite: true,
      borderColor: const Color(0xFF10B981),
      tags: ['healthy', 'quick', 'vegetarian'],
    ),
    Recipe(
      id: '3',
      title: 'Leftover Chicken Salad',
      description: 'Transform leftover chicken into a fresh meal',
      imageUrl:
          'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400&h=300&fit=crop',
      cookTime: '8 min',
      difficulty: 'Easy',
      servings: '1 serving',
      category: 'Quick',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🍗 Chicken',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+5 more',
      isFavorite: false,
      borderColor: const Color(0xFF10B981),
      tags: ['protein', 'salad', 'quick'],
    ),
    Recipe(
      id: '4',
      title: 'Smoothie Bowl',
      description: 'Perfect for fruits about to go bad',
      imageUrl:
          'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400&h=300&fit=crop',
      cookTime: '5 min',
      difficulty: 'Easy',
      servings: '1 serving',
      category: 'Healthy',
      categoryColor: const Color(0xFF8B5CF6),
      primaryIngredient: '🍓 Mixed Berries',
      ingredientColor: const Color(0xFFEDE9FE),
      ingredientTextColor: const Color(0xFF5B21B6),
      additionalIngredients: '+3 more',
      isFavorite: true,
      borderColor: const Color(0xFF8B5CF6),
      tags: ['healthy', 'breakfast', 'fruit'],
    ),
    Recipe(
      id: '5',
      title: 'Pasta Primavera',
      description: 'Use seasonal vegetables in this colorful dish',
      imageUrl:
          'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400&h=300&fit=crop',
      cookTime: '25 min',
      difficulty: 'Medium',
      servings: '4 servings',
      category: 'Healthy',
      categoryColor: const Color(0xFF8B5CF6),
      primaryIngredient: '🍝 Pasta',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+6 more',
      isFavorite: false,
      borderColor: const Color(0xFF8B5CF6),
      tags: ['pasta', 'vegetables', 'italian'],
    ),
    Recipe(
      id: '6',
      title: 'Overnight Oats',
      description: 'Prep ahead breakfast with expiring fruits',
      imageUrl:
          'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=400&h=300&fit=crop',
      cookTime: '5 min',
      difficulty: 'Easy',
      servings: '1 serving',
      category: 'Healthy',
      categoryColor: const Color(0xFF8B5CF6),
      primaryIngredient: '🥣 Oats',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+4 more',
      isFavorite: true,
      borderColor: const Color(0xFF8B5CF6),
      tags: ['breakfast', 'healthy', 'make-ahead'],
    ),
    Recipe(
      id: '7',
      title: 'Tomato Soup',
      description: 'Perfect for overripe tomatoes',
      imageUrl:
          'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=300&fit=crop',
      cookTime: '35 min',
      difficulty: 'Easy',
      servings: '4 servings',
      category: 'Use Today',
      categoryColor: const Color(0xFFEF4444),
      primaryIngredient: '🍅 Tomatoes',
      ingredientColor: const Color(0xFFFEE2E2),
      ingredientTextColor: const Color(0xFF991B1B),
      additionalIngredients: '+3 more',
      isFavorite: false,
      borderColor: const Color(0xFFEF4444),
      tags: ['soup', 'comfort', 'tomato'],
    ),
    Recipe(
      id: '8',
      title: 'Fruit Crumble',
      description: 'Rescue overripe fruits with this warm dessert',
      imageUrl:
          'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?w=400&h=300&fit=crop',
      cookTime: '45 min',
      difficulty: 'Medium',
      servings: '6 servings',
      category: 'Use Today',
      categoryColor: const Color(0xFFEF4444),
      primaryIngredient: '🍎 Mixed Fruits',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+4 more',
      isFavorite: true,
      borderColor: const Color(0xFFEF4444),
      tags: ['dessert', 'fruit', 'baking'],
    ),
    Recipe(
      id: '9',
      title: 'Fried Rice',
      description: 'Transform leftover rice and vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&h=300&fit=crop',
      cookTime: '15 min',
      difficulty: 'Easy',
      servings: '3 servings',
      category: 'Quick',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🍚 Rice',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+5 more',
      isFavorite: false,
      borderColor: const Color(0xFF10B981),
      tags: ['rice', 'asian', 'leftovers'],
    ),
    Recipe(
      id: '10',
      title: 'Green Smoothie',
      description: 'Use up leafy greens before they wilt',
      imageUrl:
          'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=400&h=300&fit=crop',
      cookTime: '5 min',
      difficulty: 'Easy',
      servings: '1 serving',
      category: 'Healthy',
      categoryColor: const Color(0xFF8B5CF6),
      primaryIngredient: '🥬 Spinach',
      ingredientColor: const Color(0xFFD1FAE5),
      ingredientTextColor: const Color(0xFF065F46),
      additionalIngredients: '+3 more',
      isFavorite: true,
      borderColor: const Color(0xFF8B5CF6),
      tags: ['healthy', 'smoothie', 'greens'],
    ),
    Recipe(
      id: '11',
      title: 'Bread Pudding',
      description: 'Give stale bread a second life',
      imageUrl:
          'https://images.unsplash.com/photo-1571197119282-7c4a2b8b8c8c?w=400&h=300&fit=crop',
      cookTime: '50 min',
      difficulty: 'Medium',
      servings: '8 servings',
      category: 'Use Today',
      categoryColor: const Color(0xFFEF4444),
      primaryIngredient: '🍞 Stale Bread',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+5 more',
      isFavorite: false,
      borderColor: const Color(0xFFEF4444),
      tags: ['dessert', 'bread', 'comfort'],
    ),
    Recipe(
      id: '12',
      title: 'Vegetable Curry',
      description: 'Spicy curry to use mixed vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&h=300&fit=crop',
      cookTime: '30 min',
      difficulty: 'Medium',
      servings: '4 servings',
      category: 'Healthy',
      categoryColor: const Color(0xFF8B5CF6),
      primaryIngredient: '🌶️ Mixed Vegetables',
      ingredientColor: const Color(0xFFD1FAE5),
      ingredientTextColor: const Color(0xFF065F46),
      additionalIngredients: '+7 more',
      isFavorite: true,
      borderColor: const Color(0xFF8B5CF6),
      tags: ['curry', 'spicy', 'vegetables'],
    ),
    Recipe(
      id: '13',
      title: 'Pancakes',
      description: 'Quick breakfast with basic ingredients',
      imageUrl:
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
      cookTime: '20 min',
      difficulty: 'Easy',
      servings: '4 servings',
      category: 'Quick',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🥞 Flour',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+4 more',
      isFavorite: false,
      borderColor: const Color(0xFF10B981),
      tags: ['breakfast', 'pancakes', 'quick'],
    ),
    Recipe(
      id: '14',
      title: 'Roasted Vegetables',
      description: 'Simple roasted vegetables with herbs',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
      cookTime: '40 min',
      difficulty: 'Easy',
      servings: '4 servings',
      category: 'Healthy',
      categoryColor: const Color(0xFF8B5CF6),
      primaryIngredient: '🥕 Root Vegetables',
      ingredientColor: const Color(0xFFD1FAE5),
      ingredientTextColor: const Color(0xFF065F46),
      additionalIngredients: '+3 more',
      isFavorite: true,
      borderColor: const Color(0xFF8B5CF6),
      tags: ['vegetables', 'roasted', 'healthy'],
    ),
    Recipe(
      id: '15',
      title: 'Meatball Soup',
      description: 'Hearty soup with leftover meat',
      imageUrl:
          'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=300&fit=crop',
      cookTime: '4 hours',
      difficulty: 'Hard',
      servings: '6 servings',
      category: 'Use Today',
      categoryColor: const Color(0xFFEF4444),
      primaryIngredient: '🍖 Ground Meat',
      ingredientColor: const Color(0xFFFEE2E2),
      ingredientTextColor: const Color(0xFF991B1B),
      additionalIngredients: '+6 more',
      isFavorite: false,
      borderColor: const Color(0xFFEF4444),
      tags: ['soup', 'meat', 'comfort'],
    ),
  ];

  // Generate a cache key for current filter state
  String get _filterKey {
    return '$selectedCategory|$searchQuery|$showFavoritesOnly|${selectedDifficulties.join(',')}|${selectedCookTimes.join(',')}';
  }

  // Optimized filtered recipes with caching
  List<Recipe> get filteredRecipes {
    final currentKey = _filterKey;

    // Return cached result if filter hasn't changed
    if (_cachedFilteredRecipes != null && _lastFilterKey == currentKey) {
      return _cachedFilteredRecipes!;
    }

    // Compute filtered recipes
    List<Recipe> filtered = List.from(allRecipes);

    // Apply search filter first (most selective)
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered =
          filtered.where((recipe) {
            return recipe.title.toLowerCase().contains(query) ||
                recipe.description.toLowerCase().contains(query) ||
                recipe.tags.any((tag) => tag.toLowerCase().contains(query));
          }).toList();
    }

    // Apply favorites filter
    if (showFavoritesOnly) {
      filtered = filtered.where((recipe) => recipe.isFavorite).toList();
    }

    // Apply category filter
    switch (selectedCategory) {
      case 'Use Soon':
        filtered =
            filtered
                .where(
                  (recipe) =>
                      recipe.category == 'Use Today' ||
                      recipe.category == 'Quick',
                )
                .toList();
        break;
      case 'Quick Meals':
        filtered =
            filtered
                .where(
                  (recipe) =>
                      recipe.category == 'Quick' ||
                      _isQuickCookTime(recipe.cookTime),
                )
                .toList();
        break;
      case 'Healthy':
        filtered =
            filtered
                .where(
                  (recipe) =>
                      recipe.category == 'Healthy' ||
                      recipe.tags.contains('healthy'),
                )
                .toList();
        break;
      case 'Favorites':
        filtered = filtered.where((recipe) => recipe.isFavorite).toList();
        break;
    }

    // Apply difficulty filter
    if (selectedDifficulties.isNotEmpty) {
      filtered =
          filtered
              .where(
                (recipe) => selectedDifficulties.contains(recipe.difficulty),
              )
              .toList();
    }

    // Apply cook time filter
    if (selectedCookTimes.isNotEmpty) {
      filtered =
          filtered
              .where((recipe) => _matchesCookTimeFilter(recipe.cookTime))
              .toList();
    }

    // Cache the result
    _cachedFilteredRecipes = filtered;
    _lastFilterKey = currentKey;

    return filtered;
  }

  // Helper method to check if cook time is quick
  bool _isQuickCookTime(String cookTime) {
    return cookTime.contains('5 min') ||
        cookTime.contains('8 min') ||
        cookTime.contains('10 min') ||
        cookTime.contains('12 min');
  }

  // Helper method to match cook time filters
  bool _matchesCookTimeFilter(String cookTime) {
    for (String timeRange in selectedCookTimes) {
      switch (timeRange) {
        case 'Under 15 min':
          if (_isQuickCookTime(cookTime)) return true;
          break;
        case '15-30 min':
          if (cookTime.contains('15 min') ||
              cookTime.contains('18 min') ||
              cookTime.contains('20 min') ||
              cookTime.contains('22 min') ||
              cookTime.contains('25 min') ||
              cookTime.contains('30 min'))
            return true;
          break;
        case 'Over 30 min':
          if (cookTime.contains('35 min') ||
              cookTime.contains('40 min') ||
              cookTime.contains('45 min') ||
              cookTime.contains('50 min') ||
              cookTime.contains('60 min') ||
              cookTime.contains('4 hours'))
            return true;
          break;
      }
    }
    return false;
  }

  List<Recipe> get displayedRecipes {
    final filtered = filteredRecipes;
    return filtered.take(displayedRecipesCount).toList();
  }

  bool get hasMoreRecipes {
    return displayedRecipesCount < filteredRecipes.length;
  }

  void _toggleFavorite(String recipeId) {
    setState(() {
      final recipeIndex = allRecipes.indexWhere(
        (recipe) => recipe.id == recipeId,
      );
      if (recipeIndex != -1) {
        allRecipes[recipeIndex] = allRecipes[recipeIndex].copyWith(
          isFavorite: !allRecipes[recipeIndex].isFavorite,
        );
      }
      // Clear cache when favorites change
      _cachedFilteredRecipes = null;
    });
  }

  void _loadMoreRecipes() async {
    if (isLoadingMore || !hasMoreRecipes) return;

    setState(() {
      isLoadingMore = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      displayedRecipesCount = (displayedRecipesCount + 6).clamp(
        0,
        allRecipes.length,
      );
      isLoadingMore = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Filter Recipes',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Difficulty Filter
                    const Text(
                      'Difficulty',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          ['Easy', 'Medium', 'Hard'].map((difficulty) {
                            final isSelected = selectedDifficulties.contains(
                              difficulty,
                            );
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    selectedDifficulties.remove(difficulty);
                                  } else {
                                    selectedDifficulties.add(difficulty);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(0xFF10B981)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFD1D5DB),
                                  ),
                                ),
                                child: Text(
                                  difficulty,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Cook Time Filter
                    const Text(
                      'Cook Time',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          ['Under 15 min', '15-30 min', 'Over 30 min'].map((
                            timeRange,
                          ) {
                            final isSelected = selectedCookTimes.contains(
                              timeRange,
                            );
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    selectedCookTimes.remove(timeRange);
                                  } else {
                                    selectedCookTimes.add(timeRange);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(0xFF10B981)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFD1D5DB),
                                  ),
                                ),
                                child: Text(
                                  timeRange,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 32),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                selectedDifficulties.clear();
                                selectedCookTimes.clear();
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _resetPagination();
                                // Clear cache when filters change
                                _cachedFilteredRecipes = null;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _resetPagination() {
    setState(() {
      displayedRecipesCount = 6;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
        _resetPagination();
        // Clear cache when search changes
        _cachedFilteredRecipes = null;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final displayed = displayedRecipes;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(title: 'Eatsoon'),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recipe Suggestions',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xFF111827),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredRecipes.length} recipes available',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showFilterBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Color(0xFF4B5563),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showFavoritesOnly = !showFavoritesOnly;
                            _resetPagination();
                            // Clear cache when favorites filter changes
                            _cachedFilteredRecipes = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                showFavoritesOnly
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            showFavoritesOnly
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color:
                                showFavoritesOnly
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF4B5563),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildUseSoonAlert(),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildCategoryTabs(),
                  const SizedBox(height: 24),
                  _buildRecipeList(displayed),
                  const SizedBox(height: 24),
                  if (hasMoreRecipes || isLoadingMore) _buildLoadMoreButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseSoonAlert() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14.4),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFFED7AA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Color(0xFFEA580C),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Use Soon!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF7C2D12),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '3 items expire today. Find recipes to use them up!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFFC2410C),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.4),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search recipes...',
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFF9CA3AF),
            height: 1.2,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['Use Soon', 'Quick Meals', 'Healthy', 'Favorites'];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Container(
            margin: EdgeInsets.only(
              right: index < categories.length - 1 ? 12 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                  _resetPagination();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEF4444) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                    height: 1.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeList(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'No recipes found for "$searchQuery"'
                  : showFavoritesOnly
                  ? 'No favorite recipes yet'
                  : 'No recipes found',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'Try searching for something else'
                  : showFavoritesOnly
                  ? 'Start adding recipes to your favorites'
                  : 'Try selecting a different category',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          recipes
              .map(
                (recipe) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildRecipeCard(recipe),
                ),
              )
              .toList(),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.4),
        border:
            recipe.borderColor != null
                ? Border(left: BorderSide(color: recipe.borderColor!, width: 4))
                : null,
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
          // Recipe Image
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14.4),
                  ),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14.4),
                  ),
                  child: Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_rounded,
                            size: 48,
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
              ),
              // Category Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: recipe.categoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recipe.category,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              // Favorite Button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(recipe.id),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      recipe.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color:
                          recipe.isFavorite
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF4B5563),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Recipe Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Recipe Info Row
                Row(
                  children: [
                    _buildInfoItem(Icons.access_time_rounded, recipe.cookTime),
                    const SizedBox(width: 16),
                    _buildInfoItem(
                      Icons.check_circle_rounded,
                      recipe.difficulty,
                    ),
                    const SizedBox(width: 16),
                    _buildInfoItem(Icons.people_rounded, recipe.servings),
                  ],
                ),
                const SizedBox(height: 12),
                // Ingredients and Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: recipe.ingredientColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recipe.primaryIngredient,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: recipe.ingredientTextColor,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recipe.additionalIngredients,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF374151),
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'View Recipe',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.2,
                          ),
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

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.4),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.4),
          onTap: isLoadingMore ? null : _loadMoreRecipes,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoadingMore) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  isLoadingMore ? 'Loading...' : 'Load More Recipes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color:
                        isLoadingMore
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF374151),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String cookTime;
  final String difficulty;
  final String servings;
  final String category;
  final Color categoryColor;
  final String primaryIngredient;
  final Color ingredientColor;
  final Color ingredientTextColor;
  final String additionalIngredients;
  final bool isFavorite;
  final Color? borderColor;
  final List<String> tags;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cookTime,
    required this.difficulty,
    required this.servings,
    required this.category,
    required this.categoryColor,
    required this.primaryIngredient,
    required this.ingredientColor,
    required this.ingredientTextColor,
    required this.additionalIngredients,
    required this.isFavorite,
    this.borderColor,
    required this.tags,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? cookTime,
    String? difficulty,
    String? servings,
    String? category,
    Color? categoryColor,
    String? primaryIngredient,
    Color? ingredientColor,
    Color? ingredientTextColor,
    String? additionalIngredients,
    bool? isFavorite,
    Color? borderColor,
    List<String>? tags,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      servings: servings ?? this.servings,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
      primaryIngredient: primaryIngredient ?? this.primaryIngredient,
      ingredientColor: ingredientColor ?? this.ingredientColor,
      ingredientTextColor: ingredientTextColor ?? this.ingredientTextColor,
      additionalIngredients:
          additionalIngredients ?? this.additionalIngredients,
      isFavorite: isFavorite ?? this.isFavorite,
      borderColor: borderColor ?? this.borderColor,
      tags: tags ?? this.tags,
    );
  }
}
