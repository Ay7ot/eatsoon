import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_soon/features/notifications/data/models/alert_model.dart';
import 'package:eat_soon/features/notifications/data/services/alert_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eat_soon/features/home/models/food_item.dart';
import 'package:eat_soon/features/inventory/data/services/inventory_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final InventoryService _inventoryService = InventoryService();
  final AlertService _alertService = AlertService();

  bool _isInitialized = false;
  static const int _expiringTodayId = 1000;
  static const int _expiringInTwoDaysId = 2000;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _requestPermissions();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _notifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      debugPrint('NotificationService initialized');
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } else if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Handle navigation to a specific screen if needed
  }

  /// Main method to reconcile all notifications based on current inventory.
  Future<void> scheduleInventoryNotifications() async {
    if (!_isInitialized) await initialize();

    try {
      final items = await _inventoryService.getFoodItemsStream().first;
      await _reconcileNotifications(items);
      debugPrint('Reconciled notifications for ${items.length} items');
    } catch (e) {
      // Catch potential auth error if user is signed out during background fetch
      debugPrint('Error scheduling notifications: $e');
    }
  }

  Future<void> _reconcileNotifications(List<FoodItem> items) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final expiringToday = <FoodItem>[];
    final expiringInTwoDays = <FoodItem>[];

    for (final item in items) {
      final expirationDay = DateTime(
        item.expirationDate.year,
        item.expirationDate.month,
        item.expirationDate.day,
      );
      final daysUntilExpiration = expirationDay.difference(today).inDays;
      if (daysUntilExpiration == 0) {
        expiringToday.add(item);
      } else if (daysUntilExpiration == 2) {
        expiringInTwoDays.add(item);
      }
    }

    final requiredIds = <int>{};
    if (expiringToday.isNotEmpty) requiredIds.add(_expiringTodayId);
    if (expiringInTwoDays.isNotEmpty) requiredIds.add(_expiringInTwoDaysId);

    final visibleAlerts = await _alertService.getVisibleAlerts();
    final visibleIds = visibleAlerts.map((a) => a.notificationId).toSet();

    // Add new notifications that should be visible but aren't
    for (final id in requiredIds.difference(visibleIds)) {
      if (id == _expiringTodayId) {
        await _showNotification(
          id: _expiringTodayId,
          title: 'Items Expiring Today! 🚨',
          body: _buildNotificationBody(expiringToday, 'expire today'),
          isUrgent: true,
        );
      } else if (id == _expiringInTwoDaysId) {
        await _showNotification(
          id: _expiringInTwoDaysId,
          title: 'Items Expiring Soon! ⏰',
          body: _buildNotificationBody(expiringInTwoDays, 'expire in 2 days'),
          isUrgent: false,
        );
      }
    }

    // Remove obsolete notifications that are visible but shouldn't be
    for (final id in visibleIds.difference(requiredIds)) {
      await _notifications.cancel(id);
      await _alertService.hideAlert(id);
    }
  }

  String _buildNotificationBody(List<FoodItem> items, String timeframe) {
    if (items.length == 1) {
      return '${items.first.name} will $timeframe. Check your pantry!';
    } else if (items.length <= 3) {
      final names = items.map((item) => item.name).join(', ');
      return '$names will $timeframe. Check your pantry!';
    } else {
      return '${items.length} items will $timeframe. Check your pantry!';
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required bool isUrgent,
  }) async {
    // Show notification on device
    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'expiration_channel',
          'Expiration Alerts',
          channelDescription: 'Notifications for expiring food items',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: isUrgent ? 'expiring_today' : 'expiring_in_two_days',
    );

    // Save alert to Firestore for persistent history
    final alert = AlertModel(
      id: id.toString(),
      notificationId: id,
      title: title,
      body: body,
      payload: isUrgent ? 'expiring_today' : 'expiring_in_two_days',
      timestamp: Timestamp.now(),
      visible: true,
      read: false,
    );
    await _alertService.saveAlert(alert);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    await _alertService.hideAllAlerts();
  }
}
