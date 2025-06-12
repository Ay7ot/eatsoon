import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(title: 'Eatsoon'),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Welcome back, ${user?.name ?? 'User'}!',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to reduce food waste?',
                  style: AppTheme.captionStyle,
                ),
                const SizedBox(height: 40),

                // Quick Actions Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildQuickActionCard(
                        context,
                        'Scan Product',
                        Icons.camera_alt,
                        AppTheme.primaryColor,
                        () {
                          // TODO: Navigate to scanner
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Scanner coming soon!'),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'View Inventory',
                        Icons.inventory,
                        AppTheme.secondaryColor,
                        () {
                          // TODO: Navigate to inventory
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Inventory coming soon!'),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'Recipe Ideas',
                        Icons.restaurant_menu,
                        AppTheme.accentColor,
                        () {
                          // TODO: Navigate to recipes
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recipes coming soon!'),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        context,
                        'Statistics',
                        Icons.analytics,
                        AppTheme.primaryColor,
                        () {
                          // TODO: Navigate to statistics
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Statistics coming soon!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
