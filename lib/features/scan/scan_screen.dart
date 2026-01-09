import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state_provider.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScanning = ref.watch(appStateProvider).isScanning;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SCAN'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isScanning ? Icons.radar : Icons.visibility,
              size: 120,
              color: isScanning ? AppColors.spectralGreen : AppColors.ghostlyPurple,
            ),
            const SizedBox(height: 24),
            Text(
              isScanning ? 'Scanning for Entities...' : 'Ready to Detect',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              isScanning
                  ? 'Looking for paranormal activity in your area'
                  : 'Tap the button to start scanning',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            FloatingActionButton.large(
              onPressed: () {
                ref.read(appStateProvider.notifier).toggleScanning();
              },
              child: Icon(
                isScanning ? Icons.stop : Icons.play_arrow,
                size: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
