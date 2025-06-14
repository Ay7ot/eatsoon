import 'package:flutter/material.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/recipes/presentation/screens/recipe_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String selectedCategory = 'Use Soon';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool showFavoritesOnly = false;
  Set<String> selectedDifficulties = {};
  Set<String> selectedCookTimes = {};
  int displayedRecipesCount = 6;
  bool isLoadingMore = false;

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
      title: 'Cherry Smoothie Bowl',
      description: 'Refreshing and nutritious breakfast option',
      imageUrl:
          'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400&h=300&fit=crop',
      cookTime: '10 min',
      difficulty: 'Easy',
      servings: '2 servings',
      category: 'Quick',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🍒 Cherries',
      ingredientColor: const Color(0xFFFEE2E2),
      ingredientTextColor: const Color(0xFF991B1B),
      additionalIngredients: '+2 more',
      isFavorite: true,
      borderColor: null,
      tags: ['smoothie', 'healthy', 'breakfast'],
    ),
    Recipe(
      id: '3',
      title: 'Mediterranean Salad',
      description: 'Fresh and vibrant salad with seasonal vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
      cookTime: '15 min',
      difficulty: 'Easy',
      servings: '4 servings',
      category: 'Healthy',
      categoryColor: const Color(0xFF3B82F6),
      primaryIngredient: '🥬 Lettuce',
      ingredientColor: const Color(0xFFD1FAE5),
      ingredientTextColor: const Color(0xFF065F46),
      additionalIngredients: '+5 more',
      isFavorite: false,
      borderColor: null,
      tags: ['salad', 'healthy', 'mediterranean'],
    ),
    Recipe(
      id: '4',
      title: 'Garlic Green Beans',
      description: 'Simple and flavorful side dish',
      imageUrl:
          'https://images.unsplash.com/photo-1628773822503-930a7eaecf80?w=400&h=300&fit=crop',
      cookTime: '20 min',
      difficulty: 'Easy',
      servings: '4 servings',
      category: 'Veggie',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🫘 Green Beans',
      ingredientColor: const Color(0xFFD1FAE5),
      ingredientTextColor: const Color(0xFF065F46),
      additionalIngredients: '+2 more',
      isFavorite: false,
      borderColor: null,
      tags: ['vegetables', 'side dish', 'garlic'],
    ),
    Recipe(
      id: '5',
      title: 'Chocolate Chip Cookies',
      description: 'Classic homemade cookies that everyone loves',
      imageUrl:
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400&h=300&fit=crop',
      cookTime: '25 min',
      difficulty: 'Medium',
      servings: '24 cookies',
      category: 'Dessert',
      categoryColor: const Color(0xFF8B5CF6),
      primaryIngredient: '🍫 Chocolate',
      ingredientColor: const Color(0xFFF3E8FF),
      ingredientTextColor: const Color(0xFF581C87),
      additionalIngredients: '+4 more',
      isFavorite: true,
      borderColor: null,
      tags: ['cookies', 'dessert', 'chocolate'],
    ),
    Recipe(
      id: '6',
      title: 'Avocado Toast',
      description: 'Quick and healthy breakfast or snack',
      imageUrl:
          'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=400&h=300&fit=crop',
      cookTime: '5 min',
      difficulty: 'Easy',
      servings: '1 serving',
      category: 'Quick',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🥑 Avocado',
      ingredientColor: const Color(0xFFD1FAE5),
      ingredientTextColor: const Color(0xFF065F46),
      additionalIngredients: '+2 more',
      isFavorite: false,
      borderColor: null,
      tags: ['toast', 'healthy', 'avocado'],
    ),
    Recipe(
      id: '7',
      title: 'Chicken Stir Fry',
      description: 'Quick and easy weeknight dinner with fresh vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&h=300&fit=crop',
      cookTime: '18 min',
      difficulty: 'Easy',
      servings: '4 servings',
      category: 'Quick',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🐔 Chicken',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+6 more',
      isFavorite: false,
      borderColor: null,
      tags: ['chicken', 'stir-fry', 'dinner'],
    ),
    Recipe(
      id: '8',
      title: 'Blueberry Pancakes',
      description: 'Fluffy pancakes bursting with fresh blueberries',
      imageUrl:
          'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?w=400&h=300&fit=crop',
      cookTime: '30 min',
      difficulty: 'Medium',
      servings: '4 servings',
      category: 'Breakfast',
      categoryColor: const Color(0xFF8B5CF6),
      primaryIngredient: '🫐 Blueberries',
      ingredientColor: const Color(0xFFDDD6FE),
      ingredientTextColor: const Color(0xFF581C87),
      additionalIngredients: '+5 more',
      isFavorite: true,
      borderColor: null,
      tags: ['pancakes', 'breakfast', 'blueberry'],
    ),
    Recipe(
      id: '9',
      title: 'Tomato Basil Pasta',
      description: 'Classic Italian pasta with fresh tomatoes and basil',
      imageUrl:
          'https://images.unsplash.com/photo-1551892374-ecf8754cf8b0?w=400&h=300&fit=crop',
      cookTime: '22 min',
      difficulty: 'Easy',
      servings: '3 servings',
      category: 'Use Today',
      categoryColor: const Color(0xFFEF4444),
      primaryIngredient: '🍅 Tomatoes',
      ingredientColor: const Color(0xFFFEE2E2),
      ingredientTextColor: const Color(0xFF991B1B),
      additionalIngredients: '+4 more',
      isFavorite: false,
      borderColor: const Color(0xFFEF4444),
      tags: ['pasta', 'italian', 'tomato'],
    ),
    Recipe(
      id: '10',
      title: 'Greek Yogurt Parfait',
      description: 'Healthy layered parfait with yogurt, berries, and granola',
      imageUrl:
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=300&fit=crop',
      cookTime: '8 min',
      difficulty: 'Easy',
      servings: '2 servings',
      category: 'Healthy',
      categoryColor: const Color(0xFF3B82F6),
      primaryIngredient: '🥛 Greek Yogurt',
      ingredientColor: const Color(0xFFDDEAFE),
      ingredientTextColor: const Color(0xFF1E40AF),
      additionalIngredients: '+3 more',
      isFavorite: true,
      borderColor: null,
      tags: ['yogurt', 'healthy', 'breakfast'],
    ),
    Recipe(
      id: '11',
      title: 'Beef Tacos',
      description: 'Spicy ground beef tacos with fresh toppings',
      imageUrl:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop',
      cookTime: '35 min',
      difficulty: 'Medium',
      servings: '6 servings',
      category: 'Dinner',
      categoryColor: const Color(0xFFF59E0B),
      primaryIngredient: '🥩 Ground Beef',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+7 more',
      isFavorite: false,
      borderColor: null,
      tags: ['tacos', 'beef', 'mexican'],
    ),
    Recipe(
      id: '12',
      title: 'Quinoa Buddha Bowl',
      description:
          'Nutritious bowl with quinoa, roasted vegetables, and tahini',
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&h=300&fit=crop',
      cookTime: '45 min',
      difficulty: 'Medium',
      servings: '2 servings',
      category: 'Healthy',
      categoryColor: const Color(0xFF3B82F6),
      primaryIngredient: '🌾 Quinoa',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+8 more',
      isFavorite: false,
      borderColor: null,
      tags: ['quinoa', 'healthy', 'bowl'],
    ),
    Recipe(
      id: '13',
      title: 'Lemon Garlic Salmon',
      description: 'Pan-seared salmon with lemon and garlic butter sauce',
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&h=300&fit=crop',
      cookTime: '20 min',
      difficulty: 'Medium',
      servings: '4 servings',
      category: 'Healthy',
      categoryColor: const Color(0xFF3B82F6),
      primaryIngredient: '🐟 Salmon',
      ingredientColor: const Color(0xFFFFE4E1),
      ingredientTextColor: const Color(0xFFDC2626),
      additionalIngredients: '+4 more',
      isFavorite: true,
      borderColor: null,
      tags: ['salmon', 'healthy', 'seafood'],
    ),
    Recipe(
      id: '14',
      title: 'Vegetable Curry',
      description: 'Aromatic curry with mixed vegetables and coconut milk',
      imageUrl:
          'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=400&h=300&fit=crop',
      cookTime: '40 min',
      difficulty: 'Medium',
      servings: '5 servings',
      category: 'Veggie',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🥕 Mixed Vegetables',
      ingredientColor: const Color(0xFFD1FAE5),
      ingredientTextColor: const Color(0xFF065F46),
      additionalIngredients: '+9 more',
      isFavorite: false,
      borderColor: null,
      tags: ['curry', 'vegetables', 'indian'],
    ),
    Recipe(
      id: '15',
      title: 'Apple Cinnamon Oatmeal',
      description: 'Warm and comforting breakfast with apples and cinnamon',
      imageUrl:
          'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=400&h=300&fit=crop',
      cookTime: '12 min',
      difficulty: 'Easy',
      servings: '2 servings',
      category: 'Quick',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🍎 Apples',
      ingredientColor: const Color(0xFFFEE2E2),
      ingredientTextColor: const Color(0xFF991B1B),
      additionalIngredients: '+3 more',
      isFavorite: false,
      borderColor: null,
      tags: ['oatmeal', 'breakfast', 'apple'],
    ),
    Recipe(
      id: '16',
      title: 'Mushroom Risotto',
      description: 'Creamy Italian risotto with wild mushrooms',
      imageUrl:
          'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=400&h=300&fit=crop',
      cookTime: '50 min',
      difficulty: 'Hard',
      servings: '4 servings',
      category: 'Dinner',
      categoryColor: const Color(0xFFF59E0B),
      primaryIngredient: '🍄 Mushrooms',
      ingredientColor: const Color(0xFFF3F4F6),
      ingredientTextColor: const Color(0xFF374151),
      additionalIngredients: '+6 more',
      isFavorite: true,
      borderColor: null,
      tags: ['risotto', 'mushroom', 'italian'],
    ),
    Recipe(
      id: '17',
      title: 'Strawberry Smoothie',
      description: 'Refreshing smoothie with fresh strawberries and yogurt',
      imageUrl:
          'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400&h=300&fit=crop',
      cookTime: '5 min',
      difficulty: 'Easy',
      servings: '1 serving',
      category: 'Quick',
      categoryColor: const Color(0xFF10B981),
      primaryIngredient: '🍓 Strawberries',
      ingredientColor: const Color(0xFFFEE2E2),
      ingredientTextColor: const Color(0xFF991B1B),
      additionalIngredients: '+2 more',
      isFavorite: false,
      borderColor: null,
      tags: ['smoothie', 'strawberry', 'healthy'],
    ),
    Recipe(
      id: '18',
      title: 'BBQ Pulled Pork',
      description: 'Slow-cooked pulled pork with tangy BBQ sauce',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop',
      cookTime: '4 hours',
      difficulty: 'Hard',
      servings: '8 servings',
      category: 'Dinner',
      categoryColor: const Color(0xFFF59E0B),
      primaryIngredient: '🐷 Pork Shoulder',
      ingredientColor: const Color(0xFFFEF3C7),
      ingredientTextColor: const Color(0xFF92400E),
      additionalIngredients: '+5 more',
      isFavorite: false,
      borderColor: null,
      tags: ['pork', 'bbq', 'slow-cooked'],
    ),
  ];

  List<Recipe> get filteredRecipes {
    List<Recipe> filtered = List.from(allRecipes);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((recipe) {
            return recipe.title.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                recipe.description.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                recipe.tags.any(
                  (tag) =>
                      tag.toLowerCase().contains(searchQuery.toLowerCase()),
                ) ||
                recipe.primaryIngredient.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
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
                      recipe.cookTime.contains('5 min') ||
                      recipe.cookTime.contains('8 min') ||
                      recipe.cookTime.contains('10 min') ||
                      recipe.cookTime.contains('12 min'),
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
          filtered.where((recipe) {
            for (String timeRange in selectedCookTimes) {
              switch (timeRange) {
                case 'Under 15 min':
                  if (recipe.cookTime.contains('5 min') ||
                      recipe.cookTime.contains('8 min') ||
                      recipe.cookTime.contains('10 min') ||
                      recipe.cookTime.contains('12 min'))
                    return true;
                  break;
                case '15-30 min':
                  if (recipe.cookTime.contains('15 min') ||
                      recipe.cookTime.contains('18 min') ||
                      recipe.cookTime.contains('20 min') ||
                      recipe.cookTime.contains('22 min') ||
                      recipe.cookTime.contains('25 min') ||
                      recipe.cookTime.contains('30 min'))
                    return true;
                  break;
                case 'Over 30 min':
                  if (recipe.cookTime.contains('35 min') ||
                      recipe.cookTime.contains('40 min') ||
                      recipe.cookTime.contains('45 min') ||
                      recipe.cookTime.contains('50 min') ||
                      recipe.cookTime.contains('60 min') ||
                      recipe.cookTime.contains('4 hours'))
                    return true;
                  break;
              }
            }
            return false;
          }).toList();
    }

    return filtered;
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
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Recipes',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Difficulty Filter
                      const Text(
                        'Difficulty',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            ['Easy', 'Medium', 'Hard'].map((difficulty) {
                              final isSelected = selectedDifficulties.contains(
                                difficulty,
                              );
                              return FilterChip(
                                label: Text(difficulty),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (selected) {
                                      selectedDifficulties.add(difficulty);
                                    } else {
                                      selectedDifficulties.remove(difficulty);
                                    }
                                  });
                                },
                                selectedColor: const Color(
                                  0xFF10B981,
                                ).withOpacity(0.2),
                                checkmarkColor: const Color(0xFF10B981),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Cook Time Filter
                      const Text(
                        'Cook Time',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            ['Under 15 min', '15-30 min', 'Over 30 min'].map((
                              timeRange,
                            ) {
                              final isSelected = selectedCookTimes.contains(
                                timeRange,
                              );
                              return FilterChip(
                                label: Text(timeRange),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (selected) {
                                      selectedCookTimes.add(timeRange);
                                    } else {
                                      selectedCookTimes.remove(timeRange);
                                    }
                                  });
                                },
                                selectedColor: const Color(
                                  0xFF10B981,
                                ).withOpacity(0.2),
                                checkmarkColor: const Color(0xFF10B981),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 30),

                      // Apply Filters Button
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
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
                  ),
                ),
          ),
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
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recipes',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF111827),
                      height: 1.3,
                    ),
                  ),
                  Row(
                    children: [
                      // Filter button
                      GestureDetector(
                        onTap: _showFilterBottomSheet,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                (selectedDifficulties.isNotEmpty ||
                                        selectedCookTimes.isNotEmpty)
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.filter_alt_outlined,
                            color:
                                (selectedDifficulties.isNotEmpty ||
                                        selectedCookTimes.isNotEmpty)
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF4B5563),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Favorites button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showFavoritesOnly = !showFavoritesOnly;
                            _resetPagination();
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
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
