import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

enum ActivityType {
  itemAdded,
  itemDeleted,
  itemUpdated,
  recipeViewed,
  recipeFavorited,
  scanPerformed,
  inventoryCleared,
}

class ActivityModel {
  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  // The user who performed the activity (only populated for family feed)
  final String? userId;
  final String? userName;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.timestamp,
    this.metadata = const {},
    this.userId,
    this.userName,
  });

  // Create activity from Firestore document
  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ActivityModel(
      id: doc.id,
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => ActivityType.itemAdded,
      ),
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      userId: data['userId'],
      userName: data['userName'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString().split('.').last,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
    };
  }

  // Helper method to get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to get activity icon based on type
  String get iconPath {
    switch (type) {
      case ActivityType.itemAdded:
        return 'assets/icons/inventory_icon.svg';
      case ActivityType.itemDeleted:
        return 'assets/icons/warning_icon.svg';
      case ActivityType.itemUpdated:
        return 'assets/icons/settings_icon.svg';
      case ActivityType.recipeViewed:
        return 'assets/icons/book_icon.svg';
      case ActivityType.recipeFavorited:
        return 'assets/icons/book_icon.svg';
      case ActivityType.scanPerformed:
        return 'assets/icons/camera_icon.svg';
      case ActivityType.inventoryCleared:
        return 'assets/icons/inventory_icon.svg';
    }
  }

  // Helper method to get activity color based on type
  int get colorValue {
    switch (type) {
      case ActivityType.itemAdded:
        return 0xFF10B981; // Green
      case ActivityType.itemDeleted:
        return 0xFFEF4444; // Red
      case ActivityType.itemUpdated:
        return 0xFF3B82F6; // Blue
      case ActivityType.recipeViewed:
        return 0xFF8B5CF6; // Purple
      case ActivityType.recipeFavorited:
        return 0xFFF59E0B; // Orange
      case ActivityType.scanPerformed:
        return 0xFF10B981; // Green
      case ActivityType.inventoryCleared:
        return 0xFF6B7280; // Gray
    }
  }

  // Localised title using translation keys
  String get i18nTitle {
    switch (type) {
      case ActivityType.itemAdded:
        return 'act_item_added_title'.trArgs([metadata['itemName'] ?? '']);
      case ActivityType.itemDeleted:
        return 'act_item_deleted_title'.trArgs([metadata['itemName'] ?? '']);
      case ActivityType.itemUpdated:
        return 'act_item_updated_title'.trArgs([metadata['itemName'] ?? '']);
      case ActivityType.recipeViewed:
        return 'act_recipe_viewed_title'.trArgs([metadata['recipeName'] ?? '']);
      case ActivityType.recipeFavorited:
        return 'act_recipe_favorited_title'.trArgs([
          metadata['recipeName'] ?? '',
        ]);
      case ActivityType.scanPerformed:
        return 'act_scan_performed_title'.tr;
      case ActivityType.inventoryCleared:
        return 'act_inventory_cleared_title'.trArgs([
          metadata['itemCount']?.toString() ?? '0',
        ]);
    }
  }

  String get i18nSubtitle {
    switch (type) {
      case ActivityType.itemAdded:
        return 'act_item_added_sub'.tr;
      case ActivityType.itemDeleted:
        return 'act_item_deleted_sub'.tr;
      case ActivityType.itemUpdated:
        return 'act_item_updated_sub'.tr;
      case ActivityType.recipeViewed:
        return 'act_recipe_viewed_sub'.tr;
      case ActivityType.recipeFavorited:
        return 'act_recipe_favorited_sub'.tr;
      case ActivityType.scanPerformed:
        return 'act_scan_performed_sub'.tr;
      case ActivityType.inventoryCleared:
        return 'act_inventory_cleared_sub'.tr;
    }
  }
}
