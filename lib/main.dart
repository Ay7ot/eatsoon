import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

// Import your app components (these will be created later)
// import 'core/theme/app_theme.dart';
// import 'core/router/app_router.dart';
// import 'features/auth/providers/auth_provider.dart';
// import 'features/inventory/providers/inventory_provider.dart';
// import 'features/scanner/providers/scanner_provider.dart';
// import 'features/notifications/providers/notification_provider.dart';
// import 'features/recipes/providers/recipe_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const EatSoonApp());
}

class EatSoonApp extends StatelessWidget {
  const EatSoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add your providers here when they're created
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ChangeNotifierProvider(create: (_) => InventoryProvider()),
        // ChangeNotifierProvider(create: (_) => ScannerProvider()),
        // ChangeNotifierProvider(create: (_) => NotificationProvider()),
        // ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: GetMaterialApp(
        title: 'Eat Soon',
        debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // Custom theme will be defined later in core/theme/app_theme.dart
          primarySwatch: Colors.green,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
        // routes: AppRouter.routes, // Will be defined later
      ),
    );
  }
}

// Temporary Splash Screen - will be replaced with proper onboarding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Eat Soon',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Reduce Food Waste',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary Home Screen - will be replaced with proper home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eat Soon'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Eat Soon!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Scan products and track expiration dates to reduce food waste.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Will navigate to scanner when implemented
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scanner feature will be implemented soon!'),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
