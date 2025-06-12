import 'package:flutter/material.dart';

/// Exact colors from the Figma design for pixel-perfect implementation
class FigmaColors {
  // Primary Status Colors
  static const Color orange = Color(0xFFF97316); // Orange for tomorrow/warning
  static const Color red = Color(0xFFEF4444); // Red for today/expired
  static const Color green = Color(0xFF78B242); // Green for UI elements (buttons, backgrounds)
  static const Color freshGreen = Color(0xFF0DE26D); // Green for fresh food status
  static const Color greenWithOpacity = Color(
    0x3378B242,
  ); // Green with 20% opacity

  // Text Colors (Gray Scale)
  static const Color textPrimary = Color(
    0xFF1F2937,
  ); // Very dark gray for headings
  static const Color textSecondary = Color(
    0xFF4B5563,
  ); // Dark gray for subheadings
  static const Color textTertiary = Color(
    0xFF6B7280,
  ); // Medium gray for body text

  // Background Colors
  static const Color backgroundLight = Color(0xFFF3F4F6); // Very light gray
  static const Color backgroundWhite = Color(0xFFFFFFFF); // Pure white

  // Helper methods for common color variations
  static Color get greenBackground => greenWithOpacity;
  static Color get orangeText => orange;
  static Color get redText => red;
  static Color get greenText => green;
  static Color get freshText => freshGreen;
}
