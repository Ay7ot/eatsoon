import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:eat_soon/features/home/models/food_item.dart';
import 'package:eat_soon/features/home/services/activity_service.dart';
import 'package:eat_soon/features/notifications/services/notification_service.dart';

class InventoryService {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ActivityService _activityService = ActivityService();

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Add a new food item to user's inventory
  Future<String?> addFoodItem({
    required String name,
    required DateTime expirationDate,
    required String category,
    required double quantity,
    required String unit,
    required String storageLocation,
    String? notes,
    String? imageUrl, // OpenFoodFacts image URL or null
    String? barcode,
  }) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      final now = DateTime.now();
      final foodItem = FoodItem(
        id: '', // Will be set by Firestore
        name: name.trim(),
        description: notes ?? '',
        imageUrl: imageUrl ?? '', // Store empty string if no image
        expirationDate: expirationDate,
        status: _calculateStatus(expirationDate),
        category: category,
        quantity: quantity,
        unit: unit,
        storageLocation: storageLocation,
        notes: notes,
        barcode: barcode,
        createdAt: now,
        updatedAt: now,
      );

      // Add to Firestore inventory collection
      final docRef = await _firestore
          .collection('inventory')
          .doc(_currentUserId)
          .collection('items')
          .add(foodItem.toFirestore());

      // Log activity
      await _activityService.logItemAdded(name, imageUrl);

      debugPrint('Food item added successfully with ID: ${docRef.id}');

      // Schedule notifications after adding item
      await NotificationService().scheduleInventoryNotifications();

      return docRef.id;
    } catch (e) {
      debugPrint('Error adding food item: $e');
      throw 'Failed to add food item: $e';
    }
  }

  // Get all food items for current user
  Future<List<FoodItem>> getFoodItems() async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      final querySnapshot =
          await _firestore
              .collection('inventory')
              .doc(_currentUserId)
              .collection('items')
              .orderBy('expirationDate', descending: false)
              .get();

      return querySnapshot.docs
          .map((doc) => FoodItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting food items: $e');
      throw 'Failed to get food items: $e';
    }
  }

  // Get food items as a stream for real-time updates
  Stream<List<FoodItem>> getFoodItemsStream() {
    if (_currentUserId == null) {
      return Stream.error('No user is currently signed in.');
    }

    return _firestore
        .collection('inventory')
        .doc(_currentUserId)
        .collection('items')
        .orderBy('expirationDate', descending: false)
        .snapshots()
        .map(
          (querySnapshot) =>
              querySnapshot.docs
                  .map((doc) => FoodItem.fromFirestore(doc))
                  .toList(),
        );
  }

  // Update an existing food item
  Future<void> updateFoodItem({
    required String itemId,
    String? name,
    DateTime? expirationDate,
    String? category,
    double? quantity,
    String? unit,
    String? storageLocation,
    String? notes,
    String? imageUrl,
    String? barcode,
  }) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      // Get current item name for activity logging
      String itemName = 'Item';
      String? currentImageUrl;
      try {
        final doc =
            await _firestore
                .collection('inventory')
                .doc(_currentUserId)
                .collection('items')
                .doc(itemId)
                .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          itemName = data['name'] ?? 'Item';
          currentImageUrl = data['imageUrl'];
        }
      } catch (e) {
        debugPrint('Error getting current item data: $e');
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name.trim();
      if (expirationDate != null) {
        updateData['expirationDate'] = Timestamp.fromDate(expirationDate);
        updateData['status'] =
            _calculateStatus(expirationDate).toString().split('.').last;
      }
      if (category != null) updateData['category'] = category;
      if (quantity != null) updateData['quantity'] = quantity;
      if (unit != null) updateData['unit'] = unit;
      if (storageLocation != null)
        updateData['storageLocation'] = storageLocation;
      if (notes != null) updateData['notes'] = notes;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (barcode != null) updateData['barcode'] = barcode;

      await _firestore
          .collection('inventory')
          .doc(_currentUserId)
          .collection('items')
          .doc(itemId)
          .update(updateData);

      // Log activity with the updated name if provided, otherwise use current name
      final activityName = name ?? itemName;
      final activityImageUrl = imageUrl ?? currentImageUrl;
      await _activityService.logItemUpdated(activityName, activityImageUrl);

      debugPrint('Food item updated successfully');
    } catch (e) {
      debugPrint('Error updating food item: $e');
      throw 'Failed to update food item: $e';
    }
  }

  // Delete a food item
  Future<void> deleteFoodItem(String itemId) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      // Get item details for activity logging before deletion
      String itemName = 'Item';
      String? imageUrl;
      try {
        final doc =
            await _firestore
                .collection('inventory')
                .doc(_currentUserId)
                .collection('items')
                .doc(itemId)
                .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          itemName = data['name'] ?? 'Item';
          imageUrl = data['imageUrl'];
        }
      } catch (e) {
        debugPrint('Error getting item data before deletion: $e');
      }

      await _firestore
          .collection('inventory')
          .doc(_currentUserId)
          .collection('items')
          .doc(itemId)
          .delete();

      // Log activity
      await _activityService.logItemDeleted(itemName, imageUrl);

      debugPrint('Food item deleted successfully');
    } catch (e) {
      debugPrint('Error deleting food item: $e');
      throw 'Failed to delete food item: $e';
    }
  }

  // Get food items expiring soon (within specified days)
  Future<List<FoodItem>> getExpiringSoonItems({int days = 3}) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final cutoffDate = today.add(Duration(days: days + 1));

      final querySnapshot =
          await _firestore
              .collection('inventory')
              .doc(_currentUserId)
              .collection('items')
              .where('expirationDate', isGreaterThanOrEqualTo: today)
              .where('expirationDate', isLessThan: cutoffDate)
              .get();

      final items =
          querySnapshot.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();

      debugPrint(
        'Found ${items.length} expiring items (including today and up to $days days).',
      );
      return items;
    } catch (e) {
      debugPrint('Error getting expiring items: $e');
      throw 'Failed to get expiring items: $e';
    }
  }

  // Calculate food item status based on expiration date
  FoodItemStatus _calculateStatus(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(
      DateTime(now.year, now.month, now.day),
    );
    final days = difference.inDays;

    if (days < 0) {
      return FoodItemStatus.expired;
    } else if (days == 0) {
      return FoodItemStatus.expiringToday;
    } else if (days <= 2) {
      return FoodItemStatus.expiringSoon;
    } else {
      return FoodItemStatus.fresh;
    }
  }

  // Search food items by name
  Future<List<FoodItem>> searchFoodItems(String query) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      final querySnapshot =
          await _firestore
              .collection('inventory')
              .doc(_currentUserId)
              .collection('items')
              .get();

      return querySnapshot.docs
          .map((doc) => FoodItem.fromFirestore(doc))
          .where(
            (item) =>
                item.name.toLowerCase().contains(query.toLowerCase()) ||
                item.category.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      debugPrint('Error searching food items: $e');
      throw 'Failed to search food items: $e';
    }
  }
}
