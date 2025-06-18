import 'package:eat_soon/core/utils/string_utils.dart';
import 'package:flutter/material.dart';

class Recipe {
  final int id;
  final String title;
  final String imageUrl;
  final int usedIngredientCount;
  final int missedIngredientCount;
  final int likes;

  // Optional detailed fields (may be absent in lightweight API responses)
  // Provide default values to avoid null checks in UI layer.
  final String description;
  final String category;
  final String difficulty;
  final String cookTime;
  final String servings;
  final String primaryIngredient;
  final bool isFavorite;

  // New fields for the detailed endpoint
  final List<Map<String, String>> ingredients;
  final List<String> instructions;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.usedIngredientCount,
    required this.missedIngredientCount,
    required this.likes,
    this.description = '',
    this.category = 'General',
    this.difficulty = 'Easy',
    this.cookTime = '30 min',
    this.servings = '4 servings',
    this.primaryIngredient = '🍅 Tomato',
    this.isFavorite = false,
    this.ingredients = const [],
    this.instructions = const [],
  });

  Recipe copyWith({
    int? id,
    String? title,
    String? imageUrl,
    int? usedIngredientCount,
    int? missedIngredientCount,
    int? likes,
    String? description,
    String? category,
    String? difficulty,
    String? cookTime,
    String? servings,
    String? primaryIngredient,
    bool? isFavorite,
    List<Map<String, String>>? ingredients,
    List<String>? instructions,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      usedIngredientCount: usedIngredientCount ?? this.usedIngredientCount,
      missedIngredientCount:
          missedIngredientCount ?? this.missedIngredientCount,
      likes: likes ?? this.likes,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      primaryIngredient: primaryIngredient ?? this.primaryIngredient,
      isFavorite: isFavorite ?? this.isFavorite,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image'],
      usedIngredientCount: json['usedIngredientCount'] ?? 0,
      missedIngredientCount: json['missedIngredientCount'] ?? 0,
      likes: json['likes'] ?? 0,
      // Safely parse optional fields when available
      description: json['summary'] ?? '',
      category:
          (json['dishTypes'] is List && json['dishTypes'].isNotEmpty)
              ? json['dishTypes'][0]
              : 'General',
      difficulty: json['difficulty'] ?? 'Easy',
      cookTime:
          json['readyInMinutes'] != null
              ? '${json['readyInMinutes']} min'
              : '30 min',
      servings:
          json['servings'] != null
              ? '${json['servings']} servings'
              : '4 servings',
      primaryIngredient: json['primaryIngredient'] ?? '🍅 Tomato',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Deserialization from the detailed Spoonacular "informationBulk" endpoint
  factory Recipe.fromDetailedJson(Map<String, dynamic> json) {
    // Helper to safely extract a list of strings from a nested structure
    List<String> extractItems(String key) {
      if (json[key] is List && json[key].isNotEmpty) {
        return (json[key][0]?['steps'] as List?)
                ?.map((step) => step['step'] as String)
                .toList() ??
            [];
      }
      return [];
    }

    return Recipe(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      imageUrl: json['image'] ?? '',
      usedIngredientCount: 0, // Not present in this endpoint, default to 0
      missedIngredientCount: 0, // Not present in this endpoint, default to 0
      likes: json['aggregateLikes'] ?? 0,
      description: stripHtmlTags(json['summary'] ?? ''),
      category:
          (json['dishTypes'] as List?)?.isNotEmpty ?? false
              ? (json['dishTypes'] as List).first
              : 'General',
      difficulty:
          (json['readyInMinutes'] ?? 45) <= 20
              ? 'Easy'
              : (json['readyInMinutes'] ?? 45) <= 45
              ? 'Medium'
              : 'Hard',
      cookTime: '${json['readyInMinutes'] ?? '?'} min',
      servings: '${json['servings'] ?? '?'} servings',
      isFavorite: false, // Cannot be determined from API, default to false
      primaryIngredient:
          (json['extendedIngredients'] as List?)?.isNotEmpty ?? false
              ? (json['extendedIngredients'] as List).first['name']
              : '',
      ingredients:
          (json['extendedIngredients'] as List?)
              ?.map(
                (ing) => <String, String>{
                  'name': ing['name']?.toString() ?? 'Unknown Ingredient',
                  'amount': '${ing['amount']} ${ing['unit']}',
                },
              )
              .toList() ??
          [],
      instructions: extractItems('analyzedInstructions'),
    );
  }

  // UI helper getters --------------------------------------------------

  // Derive a color based on category for consistent theming. Uses simple
  // mapping with a default fallback.
  Color get categoryColor {
    switch (difficulty.toLowerCase()) {
      case 'dessert':
        return const Color(0xFFEF4444);
      case 'breakfast':
        return const Color(0xFFF59E0B);
      case 'salad':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color get ingredientColor => const Color(0xFFFEF3C7);

  Color get ingredientTextColor => const Color(0xFF065F46);
}
