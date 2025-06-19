import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:eat_soon/features/home/models/food_item.dart';
import 'package:eat_soon/features/inventory/data/services/inventory_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final InventoryService _inventoryService = InventoryService();
  
  bool _isInitialized = false;
  static const int _expiringTodayId = 1000;
  static const int _expiringInTwoDaysId = 2000;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      await _requestPermissions();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation to inventory screen
  }

  /// Main method to schedule all notifications
  Future<void> scheduleInventoryNotifications() async {
    if (!_isInitialized) await initialize();

    try {
      await _notifications.cancelAll();
      final items = await _inventoryService.getFoodItemsStream().first;
      await _scheduleExpirationNotifications(items);
      debugPrint('Scheduled notifications for ${items.length} items');
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  Future<void> _scheduleExpirationNotifications(List<FoodItem> items) async {
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

    // Schedule immediate notifications
    if (expiringToday.isNotEmpty) {
      await _showNotification(
        id: _expiringTodayId,
        title: 'Items Expiring Today! 🚨',
        body: _buildNotificationBody(expiringToday, 'expire today'),
        isUrgent: true,
      );
    }

    if (expiringInTwoDays.isNotEmpty) {
      await _showNotification(
        id: _expiringInTwoDaysId,
        title: 'Items Expiring Soon! ⏰',
        body: _buildNotificationBody(expiringInTwoDays, 'expire in 2 days'),
        isUrgent: false,
      );
    }

    // Schedule daily check at 9 AM
    await _scheduleDailyCheck();
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
  }

  Future<void> _scheduleDailyCheck() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 9); // 9 AM
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      999, // Daily check ID
      'Daily Check',
      'Checking for expiring items',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_check_channel',
          'Daily Check',
          importance: Importance.low,
          priority: Priority.low,
          showWhen: false,
          playSound: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    } else if (Platform.isIOS) {
      final plugin = _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final settings = await plugin?.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    return false;
  }
}