import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/haptic_service.dart';
import 'providers/spirit_box_provider.dart';
import 'widgets/frequency_display.dart';
import 'widgets/word_display.dart';
import 'widgets/signal_bars.dart';

class SpiritBoxScreen extends ConsumerStatefulWidget {
  const SpiritBoxScreen({super.key});

  @override
  ConsumerState<SpiritBoxScreen> createState() => _SpiritBoxScreenState();
}

class _SpiritBoxScreenState extends ConsumerState<SpiritBoxScreen> {
  final _audioService = AudioService();
  final _hapticService = HapticService();
  String? _previousWord;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
  }

  @override
  void dispose() {
    _audioService.stopRadioStatic();
    super.dispose();
  }

  void _toggleScanning() {
    final isCurrentlyScanning = ref.read(spiritBoxProvider).isScanning;

    if (isCurrentlyScanning) {
      ref.read(spiritBoxProvider.notifier).stopScanning();
      _audioService.stopRadioStatic();
    } else {
      ref.read(spiritBoxProvider.notifier).startScanning();
      _audioService.playRadioStatic(volume: 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spiritBoxState = ref.watch(spiritBoxProvider);

    // Detect when a new word appears
    if (spiritBoxState.currentWord != null &&
        spiritBoxState.currentWord != _previousWord) {
      _audioService.playWordBlip();
      _hapticService.triggerLight(); // Light haptic for words
      _previousWord = spiritBoxState.currentWord;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SPIRIT BOX'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.deepVoid,
              AppColors.darkPlum.withValues(alpha: 0.5),
              AppColors.deepVoid,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Frequency display
                  FrequencyDisplay(
                    frequency: spiritBoxState.currentFrequency,
                    isScanning: spiritBoxState.isScanning,
                  ),

                  const SizedBox(height: 24),

                  // Signal bars
                  SignalBars(
                    isScanning: spiritBoxState.isScanning,
                    intensity: spiritBoxState.currentWord != null ? 0.8 : 0.2,
                  ),

                  const SizedBox(height: 24),

                  // Main word display
                  Expanded(
                    child: SingleChildScrollView(
                      child: WordDisplay(
                        currentWord: spiritBoxState.currentWord,
                        wordHistory: spiritBoxState.wordHistory,
                        isScanning: spiritBoxState.isScanning,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Scan button
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: spiritBoxState.isScanning
                          ? RadialGradient(
                              colors: [
                                AppColors.amethystGlow.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            )
                          : null,
                      boxShadow: spiritBoxState.isScanning
                          ? [
                              BoxShadow(
                                color: AppColors.amethystGlow
                                    .withValues(alpha: 0.5),
                                blurRadius: 24,
                                spreadRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                    child: FloatingActionButton.large(
                      onPressed: _toggleScanning,
                      backgroundColor: spiritBoxState.isScanning
                          ? AppColors.dustyRose
                          : AppColors.amethystGlow,
                      child: Icon(
                        spiritBoxState.isScanning
                            ? Icons.stop
                            : Icons.graphic_eq,
                        size: 48,
                        color: AppColors.deepVoid,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status text
                  Text(
                    spiritBoxState.isScanning
                        ? 'Listening through the static...'
                        : 'Await the voices',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedLavender.withValues(alpha: 0.7),
                      letterSpacing: 1.2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Flash effect when word appears
            if (spiritBoxState.currentWord != _previousWord &&
                spiritBoxState.currentWord != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: AppColors.amethystGlow.withValues(alpha: 0.15),
                  ).animate().fadeOut(duration: 200.ms),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
