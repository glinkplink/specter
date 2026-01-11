import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StaticOverlay extends StatefulWidget {
  final double intensity;

  const StaticOverlay({
    super.key,
    required this.intensity,
  });

  @override
  State<StaticOverlay> createState() => _StaticOverlayState();
}

class _StaticOverlayState extends State<StaticOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StaticNoisePainter(
            intensity: widget.intensity,
            seed: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class StaticNoisePainter extends CustomPainter {
  final double intensity;
  final double seed;

  StaticNoisePainter({
    required this.intensity,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final random = Random(seed.hashCode);
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw random noise pixels
    final pixelSize = 4.0;
    final pixelsX = (size.width / pixelSize).ceil();
    final pixelsY = (size.height / pixelSize).ceil();

    for (int x = 0; x < pixelsX; x++) {
      for (int y = 0; y < pixelsY; y++) {
        if (random.nextDouble() < intensity * 0.1) {
          final brightness = random.nextDouble();
          paint.color =
              Colors.white.withValues(alpha: brightness * intensity * 0.3);

          canvas.drawRect(
            Rect.fromLTWH(
              x * pixelSize,
              y * pixelSize,
              pixelSize,
              pixelSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(StaticNoisePainter oldDelegate) {
    return oldDelegate.intensity != intensity || oldDelegate.seed != seed;
  }
}

class VignetteOverlay extends StatelessWidget {
  final double intensity;

  const VignetteOverlay({
    super.key,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.transparent,
            AppColors.deepVoid.withValues(alpha: 0.3 + (intensity * 0.4)),
          ],
          stops: const [0.3, 1.0],
        ),
      ),
    );
  }
}

class ScreenFlicker extends StatefulWidget {
  final bool isActive;
  final Widget child;

  const ScreenFlicker({
    super.key,
    required this.isActive,
    required this.child,
  });

  @override
  State<ScreenFlicker> createState() => _ScreenFlickerState();
}

class _ScreenFlickerState extends State<ScreenFlicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ScreenFlicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class SpectralGlow extends StatefulWidget {
  final double intensity;
  final Widget child;

  const SpectralGlow({
    super.key,
    required this.intensity,
    required this.child,
  });

  @override
  State<SpectralGlow> createState() => _SpectralGlowState();
}

class _SpectralGlowState extends State<SpectralGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulseIntensity = 0.5 + (_controller.value * 0.5);
        final effectiveIntensity = widget.intensity * pulseIntensity;

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.amethystGlow
                    .withValues(alpha: effectiveIntensity * 0.3),
                blurRadius: 20 + (effectiveIntensity * 40),
                spreadRadius: 5,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

class ScanningOverlay extends StatefulWidget {
  final bool isScanning;

  const ScanningOverlay({
    super.key,
    required this.isScanning,
  });

  @override
  State<ScanningOverlay> createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<ScanningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.isScanning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ScanningOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _controller.repeat();
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isScanning) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ScanLinePainter(progress: _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class ScanLinePainter extends CustomPainter {
  final double progress;

  ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        AppColors.amethystGlow.withValues(alpha: 0.5),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTWH(0, y - 2, size.width, 4);
    final paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
