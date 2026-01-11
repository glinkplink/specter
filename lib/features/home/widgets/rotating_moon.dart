import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 3D Rotating Moon Widget with realistic texture
class RotatingMoon extends StatefulWidget {
  final double phase; // 0.0 to 1.0
  final double size;

  const RotatingMoon({
    super.key,
    required this.phase,
    required this.size,
  });

  @override
  State<RotatingMoon> createState() => _RotatingMoonState();
}

class _RotatingMoonState extends State<RotatingMoon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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
          size: Size(widget.size, widget.size),
          painter: MoonPainter(
            phase: widget.phase,
            rotation: _controller.value,
          ),
        );
      },
    );
  }
}

/// Custom painter for 3D moon with phase and realistic texture
class MoonPainter extends CustomPainter {
  final double phase; // 0.0 to 1.0 (moon cycle position)
  final double rotation; // 0.0 to 1.0 (rotation animation)

  MoonPainter({
    required this.phase,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer glow
    final glowPaint = Paint()
      ..color = AppColors.amethystGlow.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius + 6, glowPaint);

    // Draw moon base (lit portion)
    final basePaint = Paint()
      ..color = AppColors.lavenderWhite.withOpacity(0.95)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, basePaint);

    // Add realistic moon texture with craters
    _drawMoonTexture(canvas, center, radius);

    // Draw phase shadow
    if (phase > 0.03 && phase < 0.97) {
      final shadowPaint = Paint()
        ..color = AppColors.deepVoid.withOpacity(0.85)
        ..style = PaintingStyle.fill;

      // Create shadow path based on phase
      final shadowPath = Path();
      
      if (phase < 0.5) {
        // Waxing (shadow on left, growing light on right)
        final shadowWidth = (0.5 - phase) * 2;
        final ellipseWidth = radius * 2 * shadowWidth;
        
        final rect = Rect.fromCenter(
          center: center,
          width: ellipseWidth,
          height: radius * 2,
        );
        
        shadowPath.addOval(rect);
        
        // Clip to left half
        final clipPath = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx - radius, center.dy - radius)
          ..lineTo(center.dx - radius, center.dy + radius)
          ..lineTo(center.dx, center.dy + radius)
          ..close();
        
        canvas.save();
        canvas.clipPath(clipPath);
        canvas.drawPath(shadowPath, shadowPaint);
        canvas.restore();
      } else {
        // Waning (shadow on right, growing dark on left)
        final shadowWidth = (phase - 0.5) * 2;
        final ellipseWidth = radius * 2 * shadowWidth;
        
        final rect = Rect.fromCenter(
          center: center,
          width: ellipseWidth,
          height: radius * 2,
        );
        
        shadowPath.addOval(rect);
        
        // Clip to right half
        final clipPath = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy + radius)
          ..lineTo(center.dx, center.dy + radius)
          ..close();
        
        canvas.save();
        canvas.clipPath(clipPath);
        canvas.drawPath(shadowPath, shadowPaint);
        canvas.restore();
      }
    }

    // Draw subtle 3D sphere effect with gradient overlay
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3), // Light from top-left
        radius: 1.2,
        colors: [
          Colors.white.withOpacity(0.15), // Highlight
          Colors.transparent,
          AppColors.deepVoid.withOpacity(0.2), // Shadow edge
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, gradientPaint);

    // Draw rim for 3D depth
    final rimPaint = Paint()
      ..color = AppColors.amethystGlow.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 0.75, rimPaint);
  }

  // Add realistic moon texture with craters and maria
  void _drawMoonTexture(Canvas canvas, Offset center, double radius) {
    final random = Random(42); // Fixed seed for consistent craters
    
    // Draw larger maria (dark spots)
    final mariaPaint = Paint()
      ..color = AppColors.shadeMist.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    // Add 3-4 maria
    for (int i = 0; i < 4; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * radius * 0.5;
      final mariaCenter = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );
      final mariaRadius = radius * (0.15 + random.nextDouble() * 0.15);
      
      canvas.drawCircle(mariaCenter, mariaRadius, mariaPaint);
    }
    
    // Draw smaller craters
    final craterPaint = Paint()
      ..color = AppColors.deepVoid.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    
    final craterRimPaint = Paint()
      ..color = AppColors.lavenderWhite.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Add 12-15 craters
    for (int i = 0; i < 15; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * radius * 0.85;
      final craterCenter = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );
      final craterRadius = radius * (0.03 + random.nextDouble() * 0.06);
      
      // Draw crater shadow
      canvas.drawCircle(craterCenter, craterRadius, craterPaint);
      
      // Draw crater rim highlight
      canvas.drawCircle(
        Offset(craterCenter.dx - craterRadius * 0.2, craterCenter.dy - craterRadius * 0.2),
        craterRadius,
        craterRimPaint,
      );
    }
    
    // Add subtle surface texture with noise-like dots
    final texturePaint = Paint()
      ..color = AppColors.mutedLavender.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 30; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * radius * 0.95;
      final dotCenter = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );
      final dotRadius = radius * 0.01;
      
      canvas.drawCircle(dotCenter, dotRadius, texturePaint);
    }
  }

  @override
  bool shouldRepaint(MoonPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.rotation != rotation;
  }
}
