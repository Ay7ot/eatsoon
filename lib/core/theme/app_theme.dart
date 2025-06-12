import 'package:flutter/material.dart';

class AppTheme {
  // App Colors
  static const Color primaryColor = Color(0xFF2C7D4A);
  static const Color secondaryColor = Color(0xFF0DE26D);
  static const Color accentColor = Color(0xFFFDE28E);
  static const Color textPrimaryColor = Color(0xFF1C1C27);
  static const Color textSecondaryColor = Color(0xFF808D9E);
  static const Color borderColor = Color(0xFF879DBB);
  static const Color backgroundColor = Color(0xFFF9F9F9);
  static const Color whiteColor = Colors.white;
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: textPrimaryColor,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: textPrimaryColor,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontFamily: 'Inter',
    color: textPrimaryColor,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    fontFamily: 'Inter',
    color: textSecondaryColor,
  );
  
  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: whiteColor,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40),
    ),
    elevation: 0,
  );
  
  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: textPrimaryColor,
    padding: const EdgeInsets.symmetric(vertical: 16),
    side: const BorderSide(color: borderColor),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40),
    ),
  );
  
  static ButtonStyle accentButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: accentColor,
    foregroundColor: whiteColor,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40),
    ),
    elevation: 0,
  );
  
  // Input Decoration
  static InputDecoration textFieldDecoration(String hint, {Widget? suffixIcon, VoidCallback? onSuffixIconPressed}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: captionStyle,
      suffixIcon: suffixIcon != null 
          ? IconButton(icon: suffixIcon, onPressed: onSuffixIconPressed)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: secondaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: whiteColor,
    );
  }
  
  // App Theme
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Inter',
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: whiteColor,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: secondaryButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(secondaryColor),
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: headingStyle,
      bodyLarge: bodyStyle,
      bodyMedium: captionStyle,
    ),
  );
}