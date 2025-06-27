import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_soon/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:eat_soon/features/home/models/activity_model.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  
  final FirebaseFirestore _firestore = FirestoreService.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Cache of the current user's family id (fetched lazily)
  String? _cachedFamilyId;

  Future<String?> _getCurrentFamilyId() async {
    if (_cachedFamilyId != null) return _cachedFamilyId;

    if (_currentUserId == null) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(_currentUserId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      _cachedFamilyId =
          data['currentFamilyId'] ??
          data['familyId'] ??
          (data['familyIds'] is List && (data['familyIds'] as List).isNotEmpty
              ? (data['familyIds'] as List).first
              : null);
      return _cachedFamilyId;
    } catch (e) {
      debugPrint('Error fetching familyId: $e');
      return null;
    }
  }

  // Log a new activity
  Future<void> logActivity({
    required ActivityType type,
    required String title,
    required String subtitle,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_currentUserId == null) {
        debugPrint('No user signed in, skipping activity log');
        return;
      }

      final activity = ActivityModel(
        id: '', // Will be set by Firestore
        type: type,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      // Write to the user's activities collection
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('activities')
          .add(activity.toFirestore());

      // Also write to family's activities if exists
      final familyId = await _getCurrentFamilyId();
      if (familyId != null) {
        final enriched =
            activity.toFirestore()..addAll({
              'userId': _currentUserId,
              'userName': _auth.currentUser?.displayName ?? '',
            });
        await _firestore
            .collection('families')
            .doc(familyId)
            .collection('activities')
            .add(enriched);
      }

      debugPrint('Activity logged: $title');
    } catch (e) {
      debugPrint('Error logging activity: $e');
      // Don't throw error - activity logging shouldn't break app functionality
    }
  }

  // Get activities stream for real-time updates
  Stream<List<ActivityModel>> getActivitiesStream({int limit = 10}) {
    if (_currentUserId == null) {
      return Stream.error('No user is currently signed in.');
    }

    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (querySnapshot) =>
              querySnapshot.docs
                  .map((doc) => ActivityModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get recent activities (last 7 days)
  Future<List<ActivityModel>> getRecentActivities({int limit = 10}) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final querySnapshot =
          await _firestore
              .collection('users')
              .doc(_currentUserId)
              .collection('activities')
              .where(
                'timestamp',
                isGreaterThan: Timestamp.fromDate(sevenDaysAgo),
              )
              .orderBy('timestamp', descending: true)
              .limit(limit)
              .get();

      return querySnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting recent activities: $e');
      throw 'Failed to get recent activities: $e';
    }
  }

  // Clear old activities (keep only last 30 days)
  Future<void> cleanupOldActivities() async {
    try {
      if (_currentUserId == null) {
        debugPrint('No user signed in, skipping cleanup');
        return;
      }

      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final querySnapshot =
          await _firestore
              .collection('users')
              .doc(_currentUserId)
              .collection('activities')
              .where('timestamp', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
              .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('Cleaned up ${querySnapshot.docs.length} old activities');
    } catch (e) {
      debugPrint('Error cleaning up old activities: $e');
      // Don't throw error - cleanup failure shouldn't break app
    }
  }

  // Helper methods for specific activity types
  Future<void> logItemAdded(String itemName, String? imageUrl) async {
    await logActivity(
      type: ActivityType.itemAdded,
      title: '$itemName added to pantry',
      subtitle: 'New item in your inventory',
      imageUrl: imageUrl,
      metadata: {'itemName': itemName},
    );
  }

  Future<void> logItemDeleted(String itemName, String? imageUrl) async {
    await logActivity(
      type: ActivityType.itemDeleted,
      title: '$itemName removed from pantry',
      subtitle: 'Item deleted from inventory',
      imageUrl: imageUrl,
      metadata: {'itemName': itemName},
    );
  }

  Future<void> logItemUpdated(String itemName, String? imageUrl) async {
    await logActivity(
      type: ActivityType.itemUpdated,
      title: '$itemName updated',
      subtitle: 'Item details modified',
      imageUrl: imageUrl,
      metadata: {'itemName': itemName},
    );
  }

  Future<void> logRecipeViewed(String recipeName, String? imageUrl) async {
    await logActivity(
      type: ActivityType.recipeViewed,
      title: 'Viewed $recipeName recipe',
      subtitle: 'Recipe details opened',
      imageUrl: imageUrl,
      metadata: {'recipeName': recipeName},
    );
  }

  Future<void> logRecipeFavorited(String recipeName, String? imageUrl) async {
    await logActivity(
      type: ActivityType.recipeFavorited,
      title: 'Favorited $recipeName',
      subtitle: 'Recipe added to favorites',
      imageUrl: imageUrl,
      metadata: {'recipeName': recipeName},
    );
  }

  Future<void> logScanPerformed(String? detectedItem) async {
    await logActivity(
      type: ActivityType.scanPerformed,
      title: 'Product scanned',
      subtitle:
          detectedItem != null
              ? 'Detected: $detectedItem'
              : 'Barcode/text recognition performed',
      metadata: {'detectedItem': detectedItem},
    );
  }

  Future<void> logInventoryCleared(int itemCount) async {
    await logActivity(
      type: ActivityType.inventoryCleared,
      title: 'Inventory cleared',
      subtitle: '$itemCount items removed',
      metadata: {'itemCount': itemCount},
    );
  }

  // Stream of activities for a given family
  Stream<List<ActivityModel>> getFamilyActivitiesStream(
    String familyId, {
    int limit = 10,
  }) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((q) => q.docs.map((d) => ActivityModel.fromFirestore(d)).toList());
  }
}
