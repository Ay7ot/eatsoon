import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:eat_soon/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/features/splash/splash_screen.dart';

// Import your app components (these will be created later)
// import 'core/router/app_router.dart';
// import 'features/inventory/providers/inventory_provider.dart';
// import 'features/scanner/providers/scanner_provider.dart';
// import 'features/notifications/providers/notification_provider.dart';
// import 'features/recipes/providers/recipe_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Activate App Check with error handling
  try {
    await FirebaseAppCheck.instance.activate(
      // Use the debug provider for development purposes
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } catch (e) {
    // App Check activation failed, but we can continue without it in development
    debugPrint('App Check activation failed: $e');
  }

  runApp(const EatSoonApp());
}

class EatSoonApp extends StatelessWidget {
  const EatSoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here as they are created
      ],
      child: GetMaterialApp(
        title: 'Eat Soon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        // routes: AppRouter.routes, // Will be defined later
      ),
    );
  }
}
