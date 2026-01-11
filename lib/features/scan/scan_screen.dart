import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state_provider.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScanning = ref.watch(appStateProvider).isScanning;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SENSE'),
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
              AppColors.darkPlum.withOpacity(0.6),
              AppColors.deepVoid,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scanning icon with effects
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (isScanning ? AppColors.amethystGlow : AppColors.plumVeil)
                              .withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: isScanning
                          ? [
                              BoxShadow(
                                color: AppColors.amethystGlow.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isScanning ? Icons.radar : Icons.visibility,
                      size: 80,
                      color: isScanning ? AppColors.amethystGlow : AppColors.plumVeil,
                    ),
                  )
                      .animate(target: isScanning ? 1 : 0)
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1),
                        duration: 1.seconds,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.1, 1.1),
                        end: const Offset(1, 1),
                        duration: 1.seconds,
                        curve: Curves.easeInOut,
                      ),

                  const SizedBox(height: 32),

                  Text(
                    isScanning ? 'Sensing the Unseen...' : 'Awaiting Your Focus',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.lavenderWhite,
                          letterSpacing: 1,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    isScanning
                        ? 'Reaching through the veil for energy signatures'
                        : 'Open your awareness to detect what lingers nearby',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedLavender,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Scan button
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isScanning ? AppColors.dustyRose : AppColors.amethystGlow)
                              .withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: FloatingActionButton.large(
                      onPressed: () {
                        ref.read(appStateProvider.notifier).toggleScanning();
                      },
                      backgroundColor:
                          isScanning ? AppColors.dustyRose : AppColors.amethystGlow,
                      child: Icon(
                        isScanning ? Icons.stop : Icons.play_arrow,
                        size: 48,
                        color: AppColors.deepVoid,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    isScanning ? 'Tap to close the veil' : 'Tap to begin sensing',
                    style: TextStyle(
                      color: AppColors.dimLavender,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
