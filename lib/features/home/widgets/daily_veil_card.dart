import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import 'rotating_moon.dart';

/// Widget that displays today's veil reading with moon phase
class DailyVeilCard extends StatelessWidget {
  const DailyVeilCard({super.key});

  @override
  Widget build(BuildContext context) {
    final veilReading = _getVeilReading();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.twilightCard.withValues(alpha: 0.6),
            AppColors.darkPlum.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.amethystGlow.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.amethystGlow.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with moon phase
          Row(
            children: [
              // 3D Rotating Moon
              RotatingMoon(
                phase: veilReading.phaseValue,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Veil',
                      style: TextStyle(
                        color: AppColors.lavenderWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      veilReading.moonPhase,
                      style: TextStyle(
                        color: AppColors.mutedLavender.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Veil thickness indicator
          Row(
            children: [
              Text(
                'Veil:',
                style: TextStyle(
                  color: AppColors.mutedLavender,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: veilReading.thickness,
                    backgroundColor: AppColors.shadeMist.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(
                      veilReading.thickness > 0.7
                          ? AppColors.dustyRose
                          : veilReading.thickness > 0.4
                              ? AppColors.amethystGlow
                              : AppColors.zoneSafe,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                veilReading.thicknessLabel,
                style: TextStyle(
                  color: veilReading.thickness > 0.7
                      ? AppColors.dustyRose
                      : veilReading.thickness > 0.4
                          ? AppColors.amethystGlow
                          : AppColors.zoneSafe,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Daily message
          Text(
            veilReading.message,
            style: TextStyle(
              color: AppColors.lavenderWhite.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  VeilReading _getVeilReading() {
    final now = DateTime.now();

    // Calculate moon phase (approximate, 29.53 day cycle)
    final daysSinceNewMoon = (now.millisecondsSinceEpoch / 86400000) % 29.53;
    final phase = daysSinceNewMoon / 29.53;

    String moonPhase;
    double thickness;
    String thicknessLabel;
    String message;

    if (phase < 0.03 || phase > 0.97) {
      // New Moon - Thick veil
      moonPhase = 'New Moon';
      thickness = 0.2;
      thicknessLabel = 'Strong';
      message =
          'Darkness holds potential. New beginnings stir in shadow. Deep focus reveals hidden truths.';
    } else if (phase < 0.22) {
      // Waxing Crescent - Thin veil
      moonPhase = 'Waxing Crescent';
      thickness = 0.75;
      thicknessLabel = 'Thin';
      message =
          'Growth whispers beyond. The spirits sense your intention. Perfect for communion.';
    } else if (phase < 0.28) {
      // First Quarter - Moderate
      moonPhase = 'First Quarter';
      thickness = 0.5;
      thicknessLabel = 'Moderate';
      message =
          'Perfect balance. Ask and you shall receive answers. Both seeking and listening favor you.';
    } else if (phase < 0.47) {
      // Waxing Gibbous - Moderate
      moonPhase = 'Waxing Gibbous';
      thickness = 0.6;
      thicknessLabel = 'Moderate';
      message =
          'Anticipation builds. Something draws near to you. The threshold opens wider.';
    } else if (phase < 0.53) {
      // Full Moon - Thinnest veil
      moonPhase = 'Full Moon';
      thickness = 0.95;
      thicknessLabel = 'Thin';
      message =
          'The boundary dissolves. They are waiting for you. Tonight, connection comes easily.';
    } else if (phase < 0.72) {
      // Waning Gibbous - Thin
      moonPhase = 'Waning Gibbous';
      thickness = 0.75;
      thicknessLabel = 'Thin';
      message =
          'Wisdom lingers. Truths revealed now settle deeply. Reflect and commune with clarity.';
    } else if (phase < 0.78) {
      // Last Quarter - Moderate
      moonPhase = 'Last Quarter';
      thickness = 0.5;
      thicknessLabel = 'Moderate';
      message =
          'Transformation. Old connections fade, new ones form. The cycle turns in your favor.';
    } else {
      // Waning Crescent - Thin
      moonPhase = 'Waning Crescent';
      thickness = 0.7;
      thicknessLabel = 'Thin';
      message =
          'The quiet before dawn. Last whispers before renewal. What needs saying finds its voice.';
    }

    return VeilReading(
      phaseValue: phase,
      moonPhase: moonPhase,
      thickness: thickness,
      thicknessLabel: thicknessLabel,
      message: message,
    );
  }
}

class VeilReading {
  final double phaseValue;
  final String moonPhase;
  final double thickness;
  final String thicknessLabel;
  final String message;

  VeilReading({
    required this.phaseValue,
    required this.moonPhase,
    required this.thickness,
    required this.thicknessLabel,
    required this.message,
  });
}
