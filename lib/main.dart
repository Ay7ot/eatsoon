import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:eat_soon/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:eat_soon/features/notifications/services/notification_service.dart';
import 'package:eat_soon/features/notifications/services/background_service.dart';
import 'package:eat_soon/l10n/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification services
  await NotificationService().initialize();
  await BackgroundService.initialize();

  // Activate App Check with a more robust provider selection
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
    debugPrint('App Check activated successfully.');
  } catch (e) {
    // App Check activation failed.
    // If you're using App Check enforcement, this will cause issues.
    debugPrint('Error activating App Check: $e');
  }

  // Retrieve saved locale
  final prefs = await SharedPreferences.getInstance();
  final savedCode = prefs.getString('locale');
  Locale? startLocale;
  if (savedCode != null) {
    final parts = savedCode.split('_');
    if (parts.isNotEmpty) {
      startLocale = Locale(parts[0], parts.length > 1 ? parts[1] : '');
    }
  }

  runApp(EatSoonApp(startLocale: startLocale));
}

class EatSoonApp extends StatelessWidget {
  final Locale? startLocale;
  const EatSoonApp({super.key, this.startLocale});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here as they are created
      ],
      child: GetMaterialApp(
        title: 'Eat Soon',
        translations: AppTranslations(),
        locale: startLocale ?? Get.deviceLocale ?? const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        // routes: AppRouter.routes, // Will be defined later
      ),
    );
  }
}
