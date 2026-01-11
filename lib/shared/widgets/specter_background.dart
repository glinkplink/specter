import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Shared atmospheric background used across screens to keep the app feeling cohesive.
///
/// Use this as a wrapper around each screen's content.
class SpecterBackground extends StatefulWidget {
  final Widget child;
  final bool enableGrain;
  final double vignetteIntensity;
  final double accentIntensity;

  const SpecterBackground({
    super.key,
    required this.child,
    this.enableGrain = true,
    this.vignetteIntensity = 0.55,
    this.accentIntensity = 0.35,
  });

  @override
  State<SpecterBackground> createState() => _SpecterBackgroundState();
}

class _SpecterBackgroundState extends State<SpecterBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.deepVoid,
                AppColors.darkPlum.withValues(alpha: 0.75),
                AppColors.deepVoid,
              ],
            ),
          ),
        ),

        // Subtle accent bloom (helps it feel less flat)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.35),
                  radius: 1.0,
                  colors: [
                    AppColors.amethystGlow
                        .withValues(alpha: 0.18 * widget.accentIntensity),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Film grain
        if (widget.enableGrain)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GrainPainter(seed: _controller.value),
                  );
                },
              ),
            ),
          ),

        // Vignette
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.05,
                  colors: [
                    Colors.transparent,
                    AppColors.deepVoid
                        .withValues(alpha: 0.55 * widget.vignetteIntensity),
                    AppColors.deepVoid
                        .withValues(alpha: 0.85 * widget.vignetteIntensity),
                  ],
                  stops: const [0.25, 0.72, 1.0],
                ),
              ),
            ),
          ),
        ),

        widget.child,
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double seed;

  _GrainPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed.hashCode);
    final paint = Paint()..style = PaintingStyle.fill;

    // Keep this cheap: small number of dots per frame.
    const dotCount = 220;
    for (int i = 0; i < dotCount; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final alpha = 0.02 + random.nextDouble() * 0.05;
      final r = 0.6 + random.nextDouble() * 1.2;

      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => oldDelegate.seed != seed;
}
