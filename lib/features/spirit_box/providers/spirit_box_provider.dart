import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/word_bank.dart';

class SpiritBoxState {
  final bool isScanning;
  final String? currentWord;
  final double currentFrequency;
  final List<String> recentWords;
  final List<String> wordHistory;

  const SpiritBoxState({
    required this.isScanning,
    this.currentWord,
    required this.currentFrequency,
    required this.recentWords,
    required this.wordHistory,
  });

  SpiritBoxState copyWith({
    bool? isScanning,
    String? currentWord,
    double? currentFrequency,
    List<String>? recentWords,
    List<String>? wordHistory,
  }) {
    return SpiritBoxState(
      isScanning: isScanning ?? this.isScanning,
      currentWord: currentWord,
      currentFrequency: currentFrequency ?? this.currentFrequency,
      recentWords: recentWords ?? this.recentWords,
      wordHistory: wordHistory ?? this.wordHistory,
    );
  }
}

class SpiritBoxNotifier extends StateNotifier<SpiritBoxState> {
  SpiritBoxNotifier()
      : super(const SpiritBoxState(
          isScanning: false,
          currentFrequency: 88.0,
          recentWords: [],
          wordHistory: [],
        ));

  Timer? _wordTimer;
  Timer? _frequencySweepTimer;
  final _random = Random();

  // Supernatural timing variables
  bool _inRapidBurstMode = false;
  int _burstWordsRemaining = 0;

  // Frequency sweep variables
  double _sweepDirection = 1.0; // 1.0 for up, -1.0 for down

  void startScanning() {
    if (state.isScanning) return;

    // Reset sweep direction
    _sweepDirection = 1.0;

    state = state.copyWith(
      isScanning: true,
      currentWord: null,
      currentFrequency: 88.0,
      recentWords: [],
      wordHistory: [],
    );

    _startFrequencySweep();
    _scheduleNextWord();
  }

  void stopScanning() {
    if (!state.isScanning) return;

    _wordTimer?.cancel();
    _frequencySweepTimer?.cancel();
    _wordTimer = null;
    _frequencySweepTimer = null;

    state = const SpiritBoxState(
      isScanning: false,
      currentFrequency: 88.0,
      recentWords: [],
      wordHistory: [],
    );
  }

  void _startFrequencySweep() {
    _frequencySweepTimer =
        Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!state.isScanning) return;

      double newFreq;

      // 3% chance to jump to a random frequency (rare scanning jump)
      if (_random.nextDouble() < 0.03) {
        newFreq =
            88.0 + (_random.nextDouble() * 20.0); // Random freq in 88-108 range
      } else {
        // Smooth sweep with momentum - moderate speed
        final sweepSpeed =
            0.2 + (_random.nextDouble() * 0.3); // 0.2 to 0.5 MHz per update
        newFreq = state.currentFrequency + (_sweepDirection * sweepSpeed);

        // Reverse direction at boundaries
        if (newFreq >= 108.0) {
          newFreq = 108.0;
          _sweepDirection = -1.0;
        } else if (newFreq <= 88.0) {
          newFreq = 88.0;
          _sweepDirection = 1.0;
        }

        // 5% chance to reverse direction mid-sweep
        if (_random.nextDouble() < 0.05) {
          _sweepDirection *= -1;
        }
      }

      state = state.copyWith(currentFrequency: newFreq);
    });
  }

  void _scheduleNextWord() {
    if (!state.isScanning) return;

    final delay = _calculateNextDelay();

    _wordTimer = Timer(Duration(milliseconds: delay), () {
      if (!state.isScanning) return;
      _displayNextWord();
      _scheduleNextWord();
    });
  }

  int _calculateNextDelay() {
    // Check if we should enter rapid burst mode (10% chance)
    if (!_inRapidBurstMode && _random.nextDouble() < 0.10) {
      _inRapidBurstMode = true;
      _burstWordsRemaining = 2 + _random.nextInt(2); // 2-3 words
      return 300 + _random.nextInt(500); // 0.3-0.8 seconds
    }

    // If in burst mode
    if (_inRapidBurstMode) {
      _burstWordsRemaining--;
      if (_burstWordsRemaining <= 0) {
        _inRapidBurstMode = false;
        // After burst, slightly longer pause
        return 3000 + _random.nextInt(2000); // 3-5 seconds
      }
      return 300 + _random.nextInt(500); // 0.3-0.8 seconds
    }

    // Check for rare long pause (5% chance)
    if (_random.nextDouble() < 0.05) {
      return 8000 + _random.nextInt(4000); // 8-12 seconds
    }

    // Normal timing: weighted toward longer delays
    // Use exponential distribution to favor longer delays
    final baseDelay = 2000; // 2 seconds minimum
    final variance = 4000; // up to 6 seconds total

    // Weight toward longer delays using exponential curve
    final randomFactor = pow(_random.nextDouble(), 1.5).toDouble();
    final delay = baseDelay + (variance * randomFactor).toInt();

    return delay;
  }

  void _displayNextWord() {
    if (!state.isScanning) return;

    // Get a random word that hasn't been used recently
    final word = WordBank.getRandomWord(state.recentWords);

    // Update recent words list (keep last 30 to avoid repeats)
    final updatedRecent = [...state.recentWords, word];
    if (updatedRecent.length > 30) {
      updatedRecent.removeAt(0);
    }

    // Update word history (keep last 5 for display)
    final updatedHistory = [word, ...state.wordHistory];
    if (updatedHistory.length > 5) {
      updatedHistory.removeLast();
    }

    state = state.copyWith(
      currentWord: word,
      recentWords: updatedRecent,
      wordHistory: updatedHistory,
    );
  }

  @override
  void dispose() {
    stopScanning();
    super.dispose();
  }
}

final spiritBoxProvider =
    StateNotifierProvider<SpiritBoxNotifier, SpiritBoxState>((ref) {
  return SpiritBoxNotifier();
});
