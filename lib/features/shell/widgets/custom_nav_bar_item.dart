import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavBarItem extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomNavBarItem({
    super.key,
    this.icon,
    this.svgPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : assert(
         icon != null || svgPath != null,
         'Either icon or svgPath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppTheme.primaryColor;
    final Color inactiveColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]!
            : Colors.grey[600]!;

    // Get text scale factor for accessibility
    final textScaler = MediaQuery.of(context).textScaler;
    final isLargeText = textScaler.scale(1.0) > 1.2;

    // Adaptive sizing - more conservative to prevent overflow
    final iconSize = isLargeText ? 18.0 : 22.0;
    final fontSize = (isLargeText ? 9.0 : 10.0).clamp(8.0, 11.0);
    final verticalPadding = isLargeText ? 2.0 : 4.0;

    // Calculate item width based on screen size and number of items
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 32) / 5; // 5 items with padding

    return SizedBox(
      width: itemWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: activeColor.withOpacity(0.1),
          highlightColor: activeColor.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 2,
              vertical: verticalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with fixed height container
                SizedBox(
                  height: iconSize,
                  child: Center(
                    child:
                        svgPath != null
                            ? SvgPicture.asset(
                              svgPath!,
                              height: iconSize,
                              colorFilter: ColorFilter.mode(
                                isSelected ? activeColor : inactiveColor,
                                BlendMode.srcIn,
                              ),
                            )
                            : Icon(
                              icon,
                              size: iconSize,
                              color: isSelected ? activeColor : inactiveColor,
                            ),
                  ),
                ),

                // Minimal spacing between icon and text
                SizedBox(height: isLargeText ? 1 : 2),

                // Label with constrained height
                SizedBox(
                  height: fontSize + 2, // Fixed height for text
                  child: Text(
                    label,
                    style: GoogleFonts.roboto(
                      fontSize: fontSize,
                      color: isSelected ? activeColor : inactiveColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.0, // Tight line height
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler:
                        TextScaler.noScaling, // Prevent additional scaling
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
