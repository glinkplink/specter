import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state_provider.dart';
import '../../shared/widgets/specter_background.dart';
import 'providers/sensor_provider.dart';
import 'widgets/emf_gauge.dart';
import 'widgets/spooky_effects.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  void _toggleScanning() {
    final isScanning = ref.read(appStateProvider).isScanning;
    if (isScanning) {
      ref.read(appStateProvider.notifier).setScanning(false);
      ref.read(sensorProvider.notifier).stopScanning();
    } else {
      ref.read(appStateProvider.notifier).setScanning(true);
      ref.read(sensorProvider.notifier).startScanning();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isScanning = ref.watch(appStateProvider).isScanning;
    final emf = ref.watch(sensorProvider);

    final isCalibrating = isScanning &&
        emf.rawMagnetometer != null &&
        emf.currentLevel < 18 &&
        !emf.isSpike;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SENSE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SpecterBackground(
        child: Stack(
          children: [
            if (isScanning) ...[
              Positioned.fill(child: ScanningOverlay(isScanning: isScanning)),
              Positioned.fill(
                child: StaticOverlay(intensity: (emf.currentLevel / 100) * 0.6),
              ),
            ],
            Positioned.fill(
              child: VignetteOverlay(
                intensity: isScanning ? 0.55 + (emf.currentLevel / 200) : 0.55,
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      Text(
                        isScanning
                            ? (isCalibrating
                                ? 'Attuning...'
                                : emf.isSpike
                                    ? 'A Presence Spikes'
                                    : 'Sensing the Unseen')
                            : 'Awaiting Your Focus',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.lavenderWhite,
                                  letterSpacing: 1.2,
                                ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        isScanning
                            ? (isCalibrating
                                ? 'Hold still for a moment while the veil settles'
                                : 'Watch for fluctuations in the field')
                            : 'Begin a scan and listen for what lingers nearby',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.mutedLavender,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      Expanded(
                        child: Center(
                          child: SpectralGlow(
                            intensity: isScanning ? emf.currentLevel / 100 : 0,
                            child: EMFGauge(
                              level: isScanning ? emf.currentLevel : 0,
                              isSpike: isScanning && emf.isSpike,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Scan button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isScanning
                                      ? AppColors.dustyRose
                                      : AppColors.amethystGlow)
                                  .withValues(alpha: 0.35),
                              blurRadius: 26,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: FloatingActionButton.large(
                          onPressed: _toggleScanning,
                          backgroundColor: isScanning
                              ? AppColors.dustyRose
                              : AppColors.amethystGlow,
                          child: Icon(
                            isScanning ? Icons.stop : Icons.play_arrow,
                            size: 48,
                            color: AppColors.deepVoid,
                          ),
                        ),
                      )
                          .animate(target: isScanning ? 1 : 0)
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.03, 1.03),
                            duration: 900.ms,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.03, 1.03),
                            end: const Offset(1, 1),
                            duration: 900.ms,
                            curve: Curves.easeInOut,
                          ),

                      const SizedBox(height: 14),

                      Text(
                        isScanning
                            ? 'Tap to close the veil'
                            : 'Tap to begin sensing',
                        style: TextStyle(
                          color: AppColors.dimLavender,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
