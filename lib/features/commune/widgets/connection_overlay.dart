import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class ConnectionOverlay extends StatelessWidget {
  final double strength;

  const ConnectionOverlay({
    super.key,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.deepBlack,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated portal/vortex effect
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  _buildRing(180, 0.3, 8.seconds),
                  // Middle ring
                  _buildRing(140, 0.5, 6.seconds),
                  // Inner ring
                  _buildRing(100, 0.7, 4.seconds),
                  // Center glow
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.ghostlyPurple.withOpacity(strength * 0.8),
                          AppColors.ghostlyPurple.withOpacity(strength * 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.2, 1.2),
                        duration: 1.5.seconds,
                      ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Connection text
            Text(
              'ESTABLISHING CONNECTION',
              style: TextStyle(
                color: AppColors.ghostlyPurple,
                fontSize: 14,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 1.seconds)
                .then()
                .fadeOut(duration: 1.seconds),

            const SizedBox(height: 24),

            // Strength indicator
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Signal Strength',
                        style: TextStyle(
                          color: AppColors.boneWhite.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${(strength * 100).toInt()}%',
                        style: TextStyle(
                          color: AppColors.ghostlyPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: strength,
                      backgroundColor: AppColors.midGray.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.ghostlyPurple.withOpacity(0.8),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Atmospheric text
            Text(
              _getConnectionMessage(strength),
              style: TextStyle(
                color: AppColors.boneWhite.withOpacity(0.6),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildRing(double size, double opacity, Duration duration) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.ghostlyPurple.withOpacity(opacity * strength),
          width: 2,
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .rotate(duration: duration)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.1, 1.1),
          duration: duration ~/ 2,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(0.9, 0.9),
          duration: duration ~/ 2,
        );
  }

  String _getConnectionMessage(double strength) {
    if (strength < 0.3) {
      return 'Reaching across the veil...';
    } else if (strength < 0.6) {
      return 'A presence draws near...';
    } else if (strength < 0.9) {
      return 'The connection strengthens...';
    } else {
      return 'Contact established...';
    }
  }
}
