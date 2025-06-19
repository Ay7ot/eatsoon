import 'package:workmanager/workmanager.dart';
import 'package:eat_soon/features/notifications/services/notification_service.dart';

class BackgroundService {
  static const String _taskName = 'checkExpiringItems';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    // Schedule periodic background task
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(hours: 12), // Check twice daily
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize notification service and check for expiring items
      final notificationService = NotificationService();
      await notificationService.scheduleInventoryNotifications();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}