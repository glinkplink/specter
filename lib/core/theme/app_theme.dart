import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Mystical theme for Specter app
///
/// Design philosophy: Elegant, reverent, atmospheric
/// Typography: Cormorant Garamond for headers, Space Grotesk for body
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepVoid,
      colorScheme: ColorScheme.dark(
        primary: AppColors.amethystGlow,
        secondary: AppColors.plumVeil,
        tertiary: AppColors.dustyRose,
        surface: AppColors.darkPlum,
        onPrimary: AppColors.deepVoid,
        onSecondary: AppColors.lavenderWhite,
        onSurface: AppColors.lavenderWhite,
      ),

      // Text theme with elegant serif headers
      textTheme: TextTheme(
        // Display styles - elegant Cormorant Garamond for major headers
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.5,
          color: AppColors.lavenderWhite,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: AppColors.lavenderWhite,
        ),
        displaySmall: GoogleFonts.cormorantGaramond(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: AppColors.lavenderWhite,
        ),

        // Headlines - serif for section headers
        headlineLarge: GoogleFonts.cormorantGaramond(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
          color: AppColors.lavenderWhite,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
          color: AppColors.lavenderWhite,
        ),
        headlineSmall: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
          color: AppColors.lavenderWhite,
        ),

        // Title styles - serif for emphasis
        titleLarge: GoogleFonts.cormorantGaramond(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: AppColors.lavenderWhite,
        ),
        titleMedium: GoogleFonts.cormorantGaramond(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: AppColors.lavenderWhite,
        ),
        titleSmall: GoogleFonts.cormorantGaramond(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: AppColors.lavenderWhite,
        ),

        // Body text - Space Grotesk for readability
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          color: AppColors.lavenderWhite,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: AppColors.lavenderWhite,
        ),
        bodySmall: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: AppColors.lavenderWhite,
        ),

        // Labels - Space Grotesk for UI elements
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.lavenderWhite,
        ),
        labelMedium: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.lavenderWhite,
        ),
        labelSmall: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.lavenderWhite,
        ),
      ),

      // AppBar theme - elegant serif titles
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepVoid,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: AppColors.amethystGlow,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.amethystGlow,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkPlum,
        selectedItemColor: AppColors.amethystGlow,
        unselectedItemColor: AppColors.dimLavender,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Card theme
      cardTheme: const CardThemeData(
        color: AppColors.twilightCard,
        elevation: 4,
        margin: EdgeInsets.all(8),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.amethystGlow,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.amethystGlow,
        foregroundColor: AppColors.deepVoid,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amethystGlow,
          foregroundColor: AppColors.lavenderWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.amethystGlow,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.twilightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.amethystGlow, width: 1),
        ),
        hintStyle: TextStyle(
          color: AppColors.dimLavender,
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.shadeMist,
        thickness: 1,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.twilightCard,
        contentTextStyle: GoogleFonts.spaceGrotesk(
          color: AppColors.lavenderWhite,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkPlum,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Prevent instantiation
  AppTheme._();
}
