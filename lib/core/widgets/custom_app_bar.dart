import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    // The gradient colors you provided
    const Color gradientStart = Color(
      0x00E5E7EB,
    ); // #E5E7EB00 -> Transparent gray
    const Color gradientEnd = Color(0xFF0DE26D); // #0DE26D

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to settings or show settings dialog
            },
            icon: SvgPicture.asset(
              'assets/icons/settings_icon.svg',
              height: 24,
            ),
          ),
          // We can retain the existing logout functionality within a PopupMenu
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authProvider.signOut();
                  }
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: AppTheme.textPrimaryColor,
                ),
                itemBuilder:
                    (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: const [
                            Icon(
                              Icons.logout,
                              color: AppTheme.textPrimaryColor,
                            ),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
