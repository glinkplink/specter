import 'package:flutter/material.dart';

class AppColors {
  // Dark mode only - ghost app theme
  static const deepBlack = Color(0xFF0A0A0F);
  static const spectralGreen = Color(0xFF00FF88);
  static const ghostlyPurple = Color(0xFF8B5CF6);
  static const boneWhite = Color(0xFFE8E8E8);

  // Supporting colors
  static const darkGray = Color(0xFF1A1A1F);
  static const midGray = Color(0xFF2A2A2F);
  static const lightGray = Color(0xFF4A4A4F);

  // EMF Zone colors
  static const zoneSafe = Color(0xFF10B981); // Green
  static const zoneModerate = Color(0xFFFF8C00); // Orange
  static const zoneActive = Color(0xFFEF4444); // Red

  // Prevent instantiation
  AppColors._();
}
