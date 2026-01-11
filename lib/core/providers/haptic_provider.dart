import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/haptic_service.dart';

enum HapticLevel {
  low,
  medium,
  high,
}

class HapticState {
  final HapticLevel level;

  const HapticState({required this.level});

  String get displayName {
    switch (level) {
      case HapticLevel.low:
        return 'Low';
      case HapticLevel.medium:
        return 'Medium';
      case HapticLevel.high:
        return 'High';
    }
  }
}

class HapticNotifier extends StateNotifier<HapticState> {
  static const String _key = 'haptic_level';
  final _hapticService = HapticService();

  HapticNotifier() : super(const HapticState(level: HapticLevel.medium)) {
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final levelIndex = prefs.getInt(_key) ?? 1; // Default to medium
    final level = HapticLevel.values[levelIndex.clamp(0, 2)];
    state = HapticState(level: level);
    _hapticService.updateLevel(level);
  }

  Future<void> setLevel(HapticLevel level) async {
    state = HapticState(level: level);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, level.index);
    _hapticService.updateLevel(level);
  }
}

final hapticProvider =
    StateNotifierProvider<HapticNotifier, HapticState>((ref) {
  return HapticNotifier();
});
