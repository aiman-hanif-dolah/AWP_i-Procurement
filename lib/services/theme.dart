// lib/services/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Colors.blueAccent;
  static const Color secondary = Colors.lightBlue;
  static const Color background = Colors.lightBlueAccent;
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color buttonBackground = Colors.blueAccent;
  static const Color buttonText = Colors.white;
  static const Color shadow = Colors.grey;
  static const Color error = Colors.redAccent;
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    // -------------------------------------------------------------------------
    // Custom Text Theme using Google Fonts (JetBrains Mono in this example)
    // -------------------------------------------------------------------------
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300, letterSpacing: -1.5),
        displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w300, letterSpacing: -0.5),
        displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.normal),
        headlineMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.normal, letterSpacing: 0.25),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.15),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.1),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.25),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, letterSpacing: 1.5),
      ),
    ),
    // -------------------------------------------------------------------------
    // AppBar Theme (the base color is used for the gradient)
    // -------------------------------------------------------------------------
    appBarTheme: AppBarTheme(
      elevation: 4.0,
      iconTheme: const IconThemeData(color: AppColors.buttonText),
      titleTextStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.buttonText,
        ),
      ),
    ),
    // -------------------------------------------------------------------------
    // Input Decoration Theme for TextFields
    // -------------------------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: AppColors.primary),
      errorStyle: const TextStyle(color: AppColors.error),
    ),
    // -------------------------------------------------------------------------
    // Elevated Button Theme
    // -------------------------------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonBackground,
        foregroundColor: AppColors.buttonText,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    // -------------------------------------------------------------------------
    // Outlined Button Theme
    // -------------------------------------------------------------------------
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    // -------------------------------------------------------------------------
    // Text Button Theme
    // -------------------------------------------------------------------------
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    // -------------------------------------------------------------------------
    // Floating Action Button Theme
    // -------------------------------------------------------------------------
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.buttonBackground,
      foregroundColor: AppColors.buttonText,
    ),
    // -------------------------------------------------------------------------
    // Card Theme
    // -------------------------------------------------------------------------
    cardTheme: CardTheme(
      color: AppColors.cardBackground,
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    // -------------------------------------------------------------------------
    // Chip Theme
    // -------------------------------------------------------------------------
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.secondary.withOpacity(0.3),
      disabledColor: Colors.grey,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.primary,
      padding: const EdgeInsets.all(4),
      labelStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      secondaryLabelStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          color: AppColors.buttonText,
          fontWeight: FontWeight.bold,
        ),
      ),
      brightness: Brightness.light,
    ),
    // -------------------------------------------------------------------------
    // TabBar Theme
    // -------------------------------------------------------------------------
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.grey,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    // -------------------------------------------------------------------------
    // Slider Theme
    // -------------------------------------------------------------------------
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.secondary.withOpacity(0.3),
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withOpacity(0.2),
      valueIndicatorColor: AppColors.primary,
    ),
    // -------------------------------------------------------------------------
    // SnackBar Theme
    // -------------------------------------------------------------------------
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primary,
      contentTextStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          color: AppColors.buttonText,
          fontWeight: FontWeight.bold,
        ),
      ),
      actionTextColor: AppColors.buttonText,
    ),
    // -------------------------------------------------------------------------
    // Dialog Theme
    // -------------------------------------------------------------------------
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.cardBackground,
      titleTextStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      contentTextStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    // -------------------------------------------------------------------------
    // ToggleButtons Theme
    // -------------------------------------------------------------------------
    toggleButtonsTheme: ToggleButtonsThemeData(
      borderColor: AppColors.primary,
      selectedBorderColor: AppColors.primary,
      selectedColor: AppColors.buttonText,
      fillColor: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
        .copyWith(surface: AppColors.cardBackground),
  );
}
