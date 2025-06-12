import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:eat_soon/features/auth/presentation/screens/login_screen.dart';
import 'package:eat_soon/features/home/presentation/screens/home_screen.dart';
import 'package:eat_soon/features/splash/splash_screen.dart';
import 'package:eat_soon/features/shell/app_shell.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.status) {
          case AuthStatus.loading:
            return const SplashScreen();
          case AuthStatus.authenticated:
            return const AppShell();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}
