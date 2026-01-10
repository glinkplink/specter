import 'dart:async';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _ambientPlayer;
  AudioPlayer? _effectPlayer;
  AudioPlayer? _tickPlayer;
  AudioPlayer? _radioStaticPlayer;
  AudioPlayer? _wordBlipPlayer;
  AudioPlayer? _communeDronePlayer;
  AudioPlayer? _whisperPlayer;

  Timer? _tickTimer;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _ambientPlayer = AudioPlayer();
    _effectPlayer = AudioPlayer();
    _tickPlayer = AudioPlayer();
    _radioStaticPlayer = AudioPlayer();
    _wordBlipPlayer = AudioPlayer();
    _communeDronePlayer = AudioPlayer();
    _whisperPlayer = AudioPlayer();

    try {
      await _ambientPlayer!.setAsset('assets/audio/ambient_static.mp3');
      await _effectPlayer!.setAsset('assets/audio/spike_alert.mp3');
      await _tickPlayer!.setAsset('assets/audio/geiger_tick.mp3');
      await _radioStaticPlayer!.setAsset('assets/audio/radio_static.mp3');
      await _wordBlipPlayer!.setAsset('assets/audio/word_blip.mp3');
      await _communeDronePlayer!.setAsset('assets/audio/commune_drone.mp3');
      await _whisperPlayer!.setAsset('assets/audio/spirit_whisper.mp3');

      // Set ambient, radio static, and commune drone to loop
      await _ambientPlayer!.setLoopMode(LoopMode.one);
      await _radioStaticPlayer!.setLoopMode(LoopMode.one);
      await _communeDronePlayer!.setLoopMode(LoopMode.one);

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

  // Spirit Box audio methods
  Future<void> playRadioStatic({double volume = 0.3}) async {
    if (!_isInitialized) await initialize();

    try {
      await _radioStaticPlayer?.setVolume(volume);
      await _radioStaticPlayer?.play();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> stopRadioStatic() async {
    try {
      await _radioStaticPlayer?.stop();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> playWordBlip() async {
    if (!_isInitialized) await initialize();

    try {
      await _wordBlipPlayer?.seek(Duration.zero);
      await _wordBlipPlayer?.setVolume(0.5);
      await _wordBlipPlayer?.play();
    } catch (e) {
      // Ignore errors
    }
  }

  // Commune audio methods
  Future<void> playCommuneDrone({double volume = 0.2}) async {
    if (!_isInitialized) await initialize();

    try {
      await _communeDronePlayer?.setVolume(volume);
      await _communeDronePlayer?.play();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> stopCommuneDrone() async {
    try {
      await _communeDronePlayer?.stop();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> setCommuneDroneVolume(double volume) async {
    try {
      await _communeDronePlayer?.setVolume(volume);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> playWhisper() async {
    if (!_isInitialized) await initialize();

    try {
      await _whisperPlayer?.seek(Duration.zero);
      await _whisperPlayer?.setVolume(0.4);
      await _whisperPlayer?.play();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> dispose() async {
    _tickTimer?.cancel();
    await _ambientPlayer?.dispose();
    await _effectPlayer?.dispose();
    await _tickPlayer?.dispose();
    await _radioStaticPlayer?.dispose();
    await _wordBlipPlayer?.dispose();
    await _communeDronePlayer?.dispose();
    await _whisperPlayer?.dispose();

    _ambientPlayer = null;
    _effectPlayer = null;
    _tickPlayer = null;
    _radioStaticPlayer = null;
    _wordBlipPlayer = null;
    _communeDronePlayer = null;
    _whisperPlayer = null;
    _isInitialized = false;
  }
}
