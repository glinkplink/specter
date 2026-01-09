import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepBlack,
      colorScheme: ColorScheme.dark(
        primary: AppColors.spectralGreen,
        secondary: AppColors.ghostlyPurple,
        surface: AppColors.darkGray,
        onPrimary: AppColors.deepBlack,
        onSecondary: AppColors.boneWhite,
        onSurface: AppColors.boneWhite,
      ),

      // Text theme with spooky fonts
      textTheme: TextTheme(
        // Headers use Creepster for spooky effect
        displayLarge: GoogleFonts.creepster(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: AppColors.boneWhite,
        ),
        displayMedium: GoogleFonts.creepster(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: AppColors.boneWhite,
        ),
        displaySmall: GoogleFonts.creepster(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: AppColors.boneWhite,
        ),
        headlineLarge: GoogleFonts.creepster(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: AppColors.boneWhite,
        ),
        headlineMedium: GoogleFonts.creepster(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: AppColors.boneWhite,
        ),
        headlineSmall: GoogleFonts.creepster(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.boneWhite,
        ),

        // Body text uses Space Grotesk for readability
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.boneWhite,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.boneWhite,
        ),
        bodySmall: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.boneWhite,
        ),

        // Labels use Space Grotesk
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.boneWhite,
        ),
        labelMedium: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.boneWhite,
        ),
        labelSmall: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.boneWhite,
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.creepster(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.spectralGreen,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.spectralGreen,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkGray,
        selectedItemColor: AppColors.spectralGreen,
        unselectedItemColor: AppColors.lightGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Card theme
      cardTheme: const CardTheme(
        color: AppColors.darkGray,
        elevation: 4,
        margin: EdgeInsets.all(8),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.spectralGreen,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.spectralGreen,
        foregroundColor: AppColors.deepBlack,
      ),
    );
  }

  // Prevent instantiation
  AppTheme._();
}
