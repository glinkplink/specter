import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/haptic_service.dart';
import 'sensors_facade.dart';

class EMFReading {
  final double currentLevel;
  final bool isSpike;
  final MagnetometerEvent? rawMagnetometer;
  final AccelerometerEvent? rawAccelerometer;

  const EMFReading({
    required this.currentLevel,
    required this.isSpike,
    this.rawMagnetometer,
    this.rawAccelerometer,
  });

  EMFReading copyWith({
    double? currentLevel,
    bool? isSpike,
    MagnetometerEvent? rawMagnetometer,
    AccelerometerEvent? rawAccelerometer,
  }) {
    return EMFReading(
      currentLevel: currentLevel ?? this.currentLevel,
      isSpike: isSpike ?? this.isSpike,
      rawMagnetometer: rawMagnetometer ?? this.rawMagnetometer,
      rawAccelerometer: rawAccelerometer ?? this.rawAccelerometer,
    );
  }
}

class SensorNotifier extends StateNotifier<EMFReading> {
  SensorNotifier() : super(const EMFReading(currentLevel: 0, isSpike: false));

  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _spikeResetTimer;
  Timer? _mockSensorTimer;

  MagnetometerEvent? _lastMagnetometer;
  AccelerometerEvent? _lastAccelerometer;

  // Mock sensor state for web testing
  double _mockBaseLevel = 15.0;
  double _mockDriftDirection = 1.0;
  final _random = Random();

  // Haptic service
  final _hapticService = HapticService();

  // Baseline values for detecting variance
  final List<double> _magnetometerBaseline = [];
  final List<double> _accelerometerBaseline = [];
  final int _baselineSamples = 30;

  double _baselineMag = 0;
  double _baselineAcc = 0;
  bool _isCalibrated = false;

  void startScanning() {
    // Reset state
    _magnetometerBaseline.clear();
    _accelerometerBaseline.clear();
    _isCalibrated = false;

    // Use mock sensors on web (Chrome)
    if (kIsWeb) {
      _startMockSensors();
      return;
    }

    // Subscribe to magnetometer
    _magnetometerSubscription = magnetometerEventStream().listen((event) {
      _lastMagnetometer = event;
      _processSensorData();
    });

    // Subscribe to accelerometer
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      _lastAccelerometer = event;
      _processSensorData();
    });
  }

  void _startMockSensors() {
    _isCalibrated = true; // Skip calibration for mock
    _mockBaseLevel = 15.0;
    _mockDriftDirection = 1.0;

    _mockSensorTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _generateMockReading();
    });
  }

  void _generateMockReading() {
    // Drift the base level slowly
    _mockBaseLevel += _mockDriftDirection * (_random.nextDouble() * 0.5);

    // Reverse drift direction at boundaries
    if (_mockBaseLevel > 40) _mockDriftDirection = -1;
    if (_mockBaseLevel < 10) _mockDriftDirection = 1;

    // Add noise
    double emfLevel = _mockBaseLevel + (_random.nextDouble() - 0.5) * 10;

    // Random spike chance (~3% per tick = roughly every 3 seconds)
    bool triggerSpike = _random.nextDouble() < 0.03;
    if (triggerSpike) {
      emfLevel = 60 + _random.nextDouble() * 35; // Spike to 60-95
    }

    emfLevel = emfLevel.clamp(0, 100);

    final previousLevel = state.currentLevel;
    final previousSpike = state.isSpike;
    final levelChange = (emfLevel - previousLevel).abs();
    final bool isSpike = levelChange > 25 || emfLevel > 70;

    // Trigger haptic feedback when spike starts (transitions from false to true)
    if (isSpike && !previousSpike) {
      _hapticService.trigger();
    }

    if (isSpike) {
      _spikeResetTimer?.cancel();
      _spikeResetTimer = Timer(const Duration(milliseconds: 800), () {
        state = state.copyWith(isSpike: false);
      });
    }

    state = EMFReading(
      currentLevel: emfLevel,
      isSpike: isSpike,
      rawMagnetometer: null,
      rawAccelerometer: null,
    );
  }

  void stopScanning() {
    _magnetometerSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _spikeResetTimer?.cancel();
    _mockSensorTimer?.cancel();

    _magnetometerSubscription = null;
    _accelerometerSubscription = null;
    _spikeResetTimer = null;
    _mockSensorTimer = null;

    state = const EMFReading(currentLevel: 0, isSpike: false);
  }

  void _processSensorData() {
    if (_lastMagnetometer == null || _lastAccelerometer == null) return;

    final mag = _lastMagnetometer!;
    final acc = _lastAccelerometer!;

    // Calculate magnitude of magnetic field and acceleration
    final magMagnitude = sqrt(mag.x * mag.x + mag.y * mag.y + mag.z * mag.z);
    final accMagnitude = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z);

    // Build baseline during initial samples
    if (!_isCalibrated) {
      _magnetometerBaseline.add(magMagnitude);
      _accelerometerBaseline.add(accMagnitude);

      if (_magnetometerBaseline.length >= _baselineSamples) {
        _baselineMag = _magnetometerBaseline.reduce((a, b) => a + b) /
            _magnetometerBaseline.length;
        _baselineAcc = _accelerometerBaseline.reduce((a, b) => a + b) /
            _accelerometerBaseline.length;
        _isCalibrated = true;
      } else {
        // During calibration, show low activity
        state = EMFReading(
          currentLevel: (_magnetometerBaseline.length / _baselineSamples) * 20,
          isSpike: false,
          rawMagnetometer: mag,
          rawAccelerometer: acc,
        );
        return;
      }
    }

    // Calculate variance from baseline
    final magVariance = (magMagnitude - _baselineMag).abs();
    final accVariance = (accMagnitude - _baselineAcc).abs();

    // Combine variances into EMF level (0-100)
    // Weight magnetometer more heavily as it's more "EMF-like"
    final combinedVariance = (magVariance * 0.7) + (accVariance * 0.3);

    // Normalize to 0-100 range with some amplification for dramatic effect
    double emfLevel = (combinedVariance * 15).clamp(0, 100);

    // Add some randomness for more interesting readings (subtle)
    final random = Random();
    emfLevel += (random.nextDouble() - 0.5) * 5;
    emfLevel = emfLevel.clamp(0, 100);

    // Detect spikes (sudden changes)
    final previousLevel = state.currentLevel;
    final previousSpike = state.isSpike;
    final levelChange = (emfLevel - previousLevel).abs();
    final bool isSpike = levelChange > 25 || emfLevel > 70;

    // Trigger haptic feedback when spike starts (transitions from false to true)
    if (isSpike && !previousSpike) {
      _hapticService.trigger();
    }

    if (isSpike) {
      // Auto-reset spike flag after a short duration
      _spikeResetTimer?.cancel();
      _spikeResetTimer = Timer(const Duration(milliseconds: 800), () {
        state = state.copyWith(isSpike: false);
      });
    }

    state = EMFReading(
      currentLevel: emfLevel,
      isSpike: isSpike,
      rawMagnetometer: mag,
      rawAccelerometer: acc,
    );
  }

  @override
  void dispose() {
    stopScanning();
    super.dispose();
  }
}

final sensorProvider = StateNotifierProvider<SensorNotifier, EMFReading>((ref) {
  return SensorNotifier();
});
