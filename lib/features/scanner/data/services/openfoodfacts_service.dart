import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OpenFoodFactsService {
  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v0/product';

  /// Get product information from OpenFoodFacts using barcode
  Future<ProductInfo?> getProductInfo(String barcode) async {
    try {
      final url = Uri.parse('$_baseUrl/$barcode.json');
      debugPrint('Fetching product info from: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1 && data['product'] != null) {
          return ProductInfo.fromJson(data['product']);
        } else {
          debugPrint('Product not found in OpenFoodFacts database');
          return null;
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching product info: $e');
      return null;
    }
  }
}

class ProductInfo {
  final String? productName;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final String? ingredients;
  final String? barcode;

  ProductInfo({
    this.productName,
    this.brand,
    this.category,
    this.imageUrl,
    this.ingredients,
    this.barcode,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      productName: json['product_name'] ?? json['product_name_en'],
      brand: json['brands'],
      category: _extractMainCategory(json['categories']),
      imageUrl: json['image_url'] ?? json['image_front_url'],
      ingredients: json['ingredients_text'] ?? json['ingredients_text_en'],
      barcode: json['code'],
    );
  }

  static String? _extractMainCategory(String? categories) {
    if (categories == null || categories.isEmpty) return null;

    // Split categories and get the most specific one (usually the last)
    final categoryList = categories.split(',');
    if (categoryList.isNotEmpty) {
      final mainCategory = categoryList.last.trim();

      // Map to our app's categories
      final lowercaseCategory = mainCategory.toLowerCase();

      if (lowercaseCategory.contains('dairy') ||
          lowercaseCategory.contains('milk') ||
          lowercaseCategory.contains('cheese') ||
          lowercaseCategory.contains('yogurt')) {
        return 'Dairy';
      } else if (lowercaseCategory.contains('meat') ||
          lowercaseCategory.contains('beef') ||
          lowercaseCategory.contains('chicken') ||
          lowercaseCategory.contains('pork') ||
          lowercaseCategory.contains('fish')) {
        return 'Meat';
      } else if (lowercaseCategory.contains('vegetable') ||
          lowercaseCategory.contains('veggie')) {
        return 'Vegetables';
      } else if (lowercaseCategory.contains('fruit')) {
        return 'Fruits';
      } else if (lowercaseCategory.contains('grain') ||
          lowercaseCategory.contains('bread') ||
          lowercaseCategory.contains('cereal') ||
          lowercaseCategory.contains('pasta') ||
          lowercaseCategory.contains('rice')) {
        return 'Grains';
      } else if (lowercaseCategory.contains('beverage') ||
          lowercaseCategory.contains('drink') ||
          lowercaseCategory.contains('juice') ||
          lowercaseCategory.contains('soda')) {
        return 'Beverages';
      }

      // Return the original category if no mapping found
      return _capitalizeFirst(mainCategory);
    }

    return null;
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  String toString() {
    return 'ProductInfo(name: $productName, brand: $brand, category: $category)';
  }
}
