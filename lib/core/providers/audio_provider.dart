import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';

class AudioState {
  final bool enabled;
  final double volume;

  const AudioState({required this.enabled, required this.volume});

  String get displayName {
    if (!enabled) return 'Off';
    return 'On • ${(volume * 100).round()}%';
  }
}

class AudioNotifier extends StateNotifier<AudioState> {
  static const _enabledKey = 'audio_enabled';
  static const _volumeKey = 'audio_volume';

  final _audioService = AudioService();

  AudioNotifier() : super(const AudioState(enabled: true, volume: 0.7)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? true;
    final volume = (prefs.getDouble(_volumeKey) ?? 0.7).clamp(0.0, 1.0);

    state = AudioState(enabled: enabled, volume: volume);
    _audioService.updateEnabled(enabled);
    _audioService.updateMasterVolume(volume);
  }

  Future<void> setEnabled(bool enabled) async {
    state = AudioState(enabled: enabled, volume: state.volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    _audioService.updateEnabled(enabled);
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    state = AudioState(enabled: state.enabled, volume: clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, clamped);
    _audioService.updateMasterVolume(clamped);
  }
}

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});
