import 'package:flutter/material.dart';

/// Mystical color palette for Specter app
///
/// Design philosophy: Reverent, elegant, spiritual
/// Target aesthetic: Tarot apps, Victorian spiritualism, candlelit séance
class AppColors {
  // ============================================
  // MYSTICAL BACKGROUNDS (purple undertones)
  // ============================================

  /// Very dark purple-black - main background
  static const deepVoid = Color(0xFF0A0612);

  /// Dark plum - surface backgrounds, cards
  static const darkPlum = Color(0xFF1A0F2E);

  /// Card backgrounds with slight elevation
  static const twilightCard = Color(0xFF251640);

  /// Elevated surfaces, subtle highlights
  static const shadeMist = Color(0xFF342350);

  // ============================================
  // PRIMARY MYSTICAL PURPLES
  // ============================================

  /// Deep midnight purple - dark accents
  static const midnightPurple = Color(0xFF2D1B4E);

  /// Medium plum purple - secondary accent
  static const plumVeil = Color(0xFF4A2C6D);

  /// Primary accent - amethyst glow (replaces neon green)
  static const amethystGlow = Color(0xFF6B4C9A);

  // ============================================
  // ACCENT COLORS
  // ============================================

  /// Dusty rose/mauve - special highlights
  static const dustyRose = Color(0xFFB88B9D);

  /// Aged gold - premium moments, important actions
  static const mysticGold = Color(0xFFC9A961);

  /// Soft sage - optional tertiary accent
  static const sageTertiary = Color(0xFF8B9B8E);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Primary text - soft lavender white
  static const lavenderWhite = Color(0xFFE8E0F5);

  /// Secondary text - muted lavender
  static const mutedLavender = Color(0xFFB8A8CC);

  /// De-emphasized text - dim lavender
  static const dimLavender = Color(0xFF6B5B7F);

  // ============================================
  // ZONE COLORS (softer, mystical)
  // ============================================

  /// Calm zone - soft sage green
  static const zoneSafe = Color(0xFF6B8B7A);

  /// Stirring zone - muted amber
  static const zoneModerate = Color(0xFFB88B6D);

  /// Presence zone - soft rose-red
  static const zoneActive = Color(0xFFB86D7A);

  // ============================================
  // LEGACY ALIASES (for gradual migration)
  // These map old color names to new equivalents
  // ============================================

  @Deprecated('Use deepVoid instead')
  static const deepBlack = deepVoid;

  @Deprecated('Use darkPlum instead')
  static const darkGray = darkPlum;

  @Deprecated('Use twilightCard instead')
  static const midGray = twilightCard;

  @Deprecated('Use shadeMist instead')
  static const lightGray = shadeMist;

  @Deprecated('Use amethystGlow instead')
  static const spectralGreen = amethystGlow;

  @Deprecated('Use plumVeil instead')
  static const ghostlyPurple = plumVeil;

  @Deprecated('Use lavenderWhite instead')
  static const boneWhite = lavenderWhite;

  // Prevent instantiation
  AppColors._();
}
