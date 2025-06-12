import 'package:flutter/material.dart';
import 'package:eat_soon/core/theme/figma_colors.dart';

class FoodItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime expirationDate;
  final FoodItemStatus status;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.expirationDate,
    required this.status,
  });

  int get daysUntilExpiration {
    final now = DateTime.now();
    final difference = expirationDate.difference(
      DateTime(now.year, now.month, now.day),
    );
    return difference.inDays;
  }

  String get expirationText {
    final days = daysUntilExpiration;
    if (days < 0) {
      return 'Expired ${-days} days ago';
    } else if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Tomorrow';
    } else if (days <= 5) {
      return 'Fresh - $days days left';
    } else {
      return 'Expires in $days days';
    }
  }

  Color get statusColor {
    final days = daysUntilExpiration;
    if (days < 0) {
      return FigmaColors.red; // Red for expired
    } else if (days == 0) {
      return FigmaColors.red; // Red for today
    } else if (days == 1) {
      return FigmaColors.orange; // Orange for tomorrow
    } else if (days <= 2) {
      return FigmaColors.orange; // Orange for soon
    } else {
      return FigmaColors.freshGreen; // Fresh green (#0DE26D) for fresh items
    }
  }
}

enum FoodItemStatus { fresh, expiringSoon, expiringToday, expired }
