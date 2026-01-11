import 'package:flutter/services.dart';
import '../providers/haptic_provider.dart';

/// Service for haptic feedback that respects user settings
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  HapticLevel _level = HapticLevel.medium;

  /// Update the haptic level from provider
  void updateLevel(HapticLevel level) {
    _level = level;
  }

  /// Trigger haptic feedback based on current setting
  void trigger() {
    if (_level == HapticLevel.low) {
      HapticFeedback.lightImpact();
    } else if (_level == HapticLevel.medium) {
      HapticFeedback.mediumImpact();
    } else if (_level == HapticLevel.high) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Trigger light haptic (always uses light impact, regardless of setting)
  void triggerLight() {
    HapticFeedback.lightImpact();
  }

  /// Trigger selection feedback (light tap)
  void triggerSelection() {
    HapticFeedback.selectionClick();
  }
}
