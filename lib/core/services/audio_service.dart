import 'dart:async';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _ambientPlayer;
  AudioPlayer? _effectPlayer;
  AudioPlayer? _tickPlayer;

  Timer? _tickTimer;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _ambientPlayer = AudioPlayer();
    _effectPlayer = AudioPlayer();
    _tickPlayer = AudioPlayer();

    try {
      await _ambientPlayer!.setAsset('assets/audio/ambient_static.mp3');
      await _effectPlayer!.setAsset('assets/audio/spike_alert.mp3');
      await _tickPlayer!.setAsset('assets/audio/geiger_tick.mp3');

      // Set ambient to loop
      await _ambientPlayer!.setLoopMode(LoopMode.one);

      _isInitialized = true;
    } catch (e) {
      // Handle error silently - audio is optional
    }
  }

  Future<void> playAmbient({double volume = 0.3}) async {
    if (!_isInitialized) await initialize();

    try {
      await _ambientPlayer?.setVolume(volume);
      await _ambientPlayer?.play();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> stopAmbient() async {
    try {
      await _ambientPlayer?.stop();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> setAmbientVolume(double volume) async {
    try {
      await _ambientPlayer?.setVolume(volume);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> playSpike() async {
    if (!_isInitialized) await initialize();

    try {
      await _effectPlayer?.seek(Duration.zero);
      await _effectPlayer?.play();
    } catch (e) {
      // Ignore errors
    }
  }

  void startTicking({required double emfLevel}) {
    _tickTimer?.cancel();

    // Calculate tick interval based on EMF level
    // Higher level = faster ticks
    final intervalMs = _calculateTickInterval(emfLevel);

    _tickTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      _playTick();
    });
  }

  void stopTicking() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  Future<void> _playTick() async {
    if (!_isInitialized) return;

    try {
      await _tickPlayer?.seek(Duration.zero);
      await _tickPlayer?.play();
    } catch (e) {
      // Ignore errors
    }
  }

  int _calculateTickInterval(double emfLevel) {
    // Map EMF level (0-100) to tick interval (1000ms - 100ms)
    // Low readings = slow ticks, high readings = fast ticks
    if (emfLevel < 20) return 1000;
    if (emfLevel < 40) return 700;
    if (emfLevel < 60) return 400;
    if (emfLevel < 80) return 200;
    return 100;
  }

  void updateTickRate(double emfLevel) {
    if (_tickTimer != null && _tickTimer!.isActive) {
      startTicking(emfLevel: emfLevel);
    }
  }

  Future<void> dispose() async {
    _tickTimer?.cancel();
    await _ambientPlayer?.dispose();
    await _effectPlayer?.dispose();
    await _tickPlayer?.dispose();

    _ambientPlayer = null;
    _effectPlayer = null;
    _tickPlayer = null;
    _isInitialized = false;
  }
}
