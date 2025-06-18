import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_soon/core/theme/figma_colors.dart';

class FoodItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl; // OpenFoodFacts image URL or empty string
  final DateTime expirationDate;
  final FoodItemStatus status;
  final String category;
  final double quantity;
  final String unit;
  final String storageLocation;
  final String? notes;
  final String? barcode;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.expirationDate,
    required this.status,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.storageLocation,
    this.notes,
    this.barcode,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create FoodItem from Firestore document
  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodItem(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '', // Empty string if no image
      expirationDate: (data['expirationDate'] as Timestamp).toDate(),
      status: FoodItemStatus.values.firstWhere(
        (status) => status.toString() == 'FoodItemStatus.${data['status']}',
        orElse: () => FoodItemStatus.fresh,
      ),
      category: data['category'] ?? 'Dairy',
      quantity: (data['quantity'] ?? 1.0).toDouble(),
      unit: data['unit'] ?? 'Pieces',
      storageLocation: data['storageLocation'] ?? 'Refrigerator',
      notes: data['notes'],
      barcode: data['barcode'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert FoodItem to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl, // Store URL or empty string
      'expirationDate': Timestamp.fromDate(expirationDate),
      'status': status.toString().split('.').last,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'storageLocation': storageLocation,
      'notes': notes,
      'barcode': barcode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method for updating food item data
  FoodItem copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    DateTime? expirationDate,
    FoodItemStatus? status,
    String? category,
    double? quantity,
    String? unit,
    String? storageLocation,
    String? notes,
    String? barcode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      expirationDate: expirationDate ?? this.expirationDate,
      status: status ?? this.status,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      storageLocation: storageLocation ?? this.storageLocation,
      notes: notes ?? this.notes,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

  @override
  String toString() {
    return 'FoodItem(id: $id, name: $name, category: $category, quantity: $quantity $unit, expires: $expirationDate)';
  }
}

enum FoodItemStatus { fresh, expiringSoon, expiringToday, expired }
