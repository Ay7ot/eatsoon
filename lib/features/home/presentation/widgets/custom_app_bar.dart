import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:eat_soon/features/shell/app_shell.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    const Color gradientStart = Color(0x00E5E7EB);
    const Color gradientEnd = Color(0xFF0DE26D);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.5, 1.0],
        ),
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 0.8),
        ),
      ),
      child: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: Text(
          title,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryColor,
            fontSize: 26,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              // Navigate to profile tab (index 4) using AppShell navigation
              final shellState = AppShell.shellKey.currentState;
              if (shellState != null) {
                shellState.navigateToTab(4); // Profile tab is at index 4
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10.0),
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: AppTheme.whiteColor,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/settings_icon.svg',
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppTheme.secondaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65.0);
}
