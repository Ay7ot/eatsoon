import 'dart:convert';
import 'package:eat_soon/features/recipes/data/models/recipe_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RecipeService {
  final String _baseUrl = 'https://api.spoonacular.com/recipes';

  /// Lazily fetch the API key so that this class can be instantiated before
  /// `dotenv.load()` completes without throwing a [NotInitializedError].
  String? get _apiKey {
    // Access every time to also allow hot-reload updates while debugging.
    return dotenv.env['SPOONACULAR_API_KEY'];
  }

  Future<List<Recipe>> getRecipesByIngredients(
    List<String> ingredients, {
    int limit = 20,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception(
        'Spoonacular API key is missing. Ensure .env is loaded and the key is defined.',
      );
    }

    if (ingredients.isEmpty) {
      return [];
    }

    final String ingredientsString = ingredients.join(',');
    final Uri uri = Uri.parse(
      '$_baseUrl/findByIngredients?ingredients=$ingredientsString&number=$limit&ranking=2',
    );

    final response = await http.get(uri, headers: {'x-api-key': _apiKey!});

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes: ${response.body}');
    }
  }

  // Get detailed information for a list of recipes
  Future<List<Recipe>> getRecipesInformationBulk(List<int> ids) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Spoonacular API key is missing from .env');
    }

    if (ids.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/informationBulk?ids=${ids.join(',')}&apiKey=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Recipe.fromDetailedJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load recipe details. Status: ${response.statusCode}',
      );
    }
  }
}
