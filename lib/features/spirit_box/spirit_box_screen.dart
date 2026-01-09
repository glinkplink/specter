import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/audio_service.dart';
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
      _previousWord = spiritBoxState.currentWord;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SPIRIT BOX'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.deepBlack,
              AppColors.darkGray.withOpacity(0.5),
              AppColors.deepBlack,
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
                                AppColors.spectralGreen.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            )
                          : null,
                      boxShadow: spiritBoxState.isScanning
                          ? [
                              BoxShadow(
                                color: AppColors.spectralGreen.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                    child: FloatingActionButton.large(
                      onPressed: _toggleScanning,
                      backgroundColor: spiritBoxState.isScanning
                          ? AppColors.zoneActive
                          : AppColors.ghostlyPurple,
                      child: Icon(
                        spiritBoxState.isScanning ? Icons.stop : Icons.graphic_eq,
                        size: 48,
                        color: AppColors.boneWhite,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status text
                  Text(
                    spiritBoxState.isScanning
                        ? 'Scanning frequencies...'
                        : 'Ready to communicate',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.boneWhite.withOpacity(0.6),
                      letterSpacing: 1.2,
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
                    color: AppColors.spectralGreen.withOpacity(0.1),
                  )
                      .animate()
                      .fadeOut(duration: 200.ms),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
