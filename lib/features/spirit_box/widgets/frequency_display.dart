import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class FrequencyDisplay extends StatelessWidget {
  final double frequency;
  final bool isScanning;

  const FrequencyDisplay({
    super.key,
    required this.frequency,
    required this.isScanning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkGray.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isScanning
              ? AppColors.spectralGreen.withOpacity(0.5)
              : AppColors.lightGray.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isScanning
            ? [
                BoxShadow(
                  color: AppColors.spectralGreen.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // FM label
          Text(
            'FM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.boneWhite.withOpacity(0.5),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),

          // Frequency number
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                frequency.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isScanning ? AppColors.spectralGreen : AppColors.boneWhite,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'MHz',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.boneWhite.withOpacity(0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Frequency bar
          _buildFrequencyBar(),
        ],
      ),
    );
  }

  Widget _buildFrequencyBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final position = ((frequency - 88) / 20) * barWidth;

        return SizedBox(
          height: 40,
          child: Stack(
            children: [
              // Background bar
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Frequency markers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMarker('88'),
                  _buildMarker('94'),
                  _buildMarker('100'),
                  _buildMarker('108'),
                ],
              ),

              // Current position indicator
              if (isScanning)
                Positioned(
                  left: position.clamp(0, barWidth - 3),
                  child: Container(
                    width: 3,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.spectralGreen,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.spectralGreen.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(duration: 600.ms)
                      .then()
                      .fadeOut(duration: 600.ms),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarker(String label) {
    return Column(
      children: [
        Container(
          width: 2,
          height: 8,
          color: AppColors.boneWhite.withOpacity(0.5),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.boneWhite.withOpacity(0.5),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
