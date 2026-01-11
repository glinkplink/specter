import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EMFGauge extends StatefulWidget {
  final double level;
  final bool isSpike;

  const EMFGauge({
    super.key,
    required this.level,
    required this.isSpike,
  });

  @override
  State<EMFGauge> createState() => _EMFGaugeState();
}

class _EMFGaugeState extends State<EMFGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentLevel = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(EMFGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _animateToLevel(widget.level);
    }
  }

  void _animateToLevel(double newLevel) {
    _animation = Tween<double>(
      begin: _currentLevel,
      end: newLevel,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _currentLevel = newLevel;
    _controller.forward(from: 0);
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
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing glow effect
            if (_animation.value > 30)
              Container(
                width: 280 + (_animation.value * 0.5),
                height: 280 + (_animation.value * 0.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getZoneColor(_animation.value)
                          .withValues(alpha: 0.3),
                      blurRadius: 40 + (_animation.value * 0.3),
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),

            // Spike glow
            if (widget.isSpike)
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dustyRose.withValues(alpha: 0.6),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),

            // Main gauge
            CustomPaint(
              size: const Size(280, 280),
              painter: EMFGaugePainter(
                level: _animation.value,
                isSpike: widget.isSpike,
              ),
            ),

            // Digital readout
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 180),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.deepVoid.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getZoneColor(_animation.value)
                          .withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _animation.value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getZoneColor(_animation.value),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getZoneLabel(_animation.value),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getZoneColor(_animation.value),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Color _getZoneColor(double level) {
    if (level < 30) return AppColors.zoneSafe;
    if (level < 60) return AppColors.zoneModerate;
    return AppColors.zoneActive;
  }

  String _getZoneLabel(double level) {
    if (level < 30) return 'CALM';
    if (level < 60) return 'STIRRING';
    return 'PRESENCE';
  }
}

class EMFGaugePainter extends CustomPainter {
  final double level;
  final bool isSpike;

  EMFGaugePainter({
    required this.level,
    required this.isSpike,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw outer circle
    final outerPaint = Paint()
      ..color = AppColors.twilightCard
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, outerPaint);

    // Draw zone arcs with mystical purple tones
    _drawZoneArc(canvas, center, radius, 0, 30, AppColors.zoneSafe);
    _drawZoneArc(canvas, center, radius, 30, 60, AppColors.zoneModerate);
    _drawZoneArc(canvas, center, radius, 60, 100, AppColors.zoneActive);

    // Draw tick marks
    _drawTickMarks(canvas, center, radius);

    // Draw needle
    _drawNeedle(canvas, center, radius);
  }

  void _drawZoneArc(Canvas canvas, Offset center, double radius,
      double startLevel, double endLevel, Color color) {
    const startAngle = -225.0; // -135 degrees (bottom left)
    const sweepAngle = 270.0; // Total sweep of gauge

    final normalizedStart = startLevel / 100;
    final normalizedEnd = endLevel / 100;

    final arcStartAngle =
        (startAngle + (sweepAngle * normalizedStart)) * pi / 180;
    final arcSweepAngle =
        (sweepAngle * (normalizedEnd - normalizedStart)) * pi / 180;

    final arcPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      arcStartAngle,
      arcSweepAngle,
      false,
      arcPaint,
    );
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    const startAngle = -225.0;
    const sweepAngle = 270.0;
    const tickCount = 11;

    final tickPaint = Paint()
      ..color = AppColors.mutedLavender.withValues(alpha: 0.5)
      ..strokeWidth = 2;

    for (int i = 0; i < tickCount; i++) {
      final angle =
          (startAngle + (sweepAngle * i / (tickCount - 1))) * pi / 180;
      final startX = center.dx + (radius - 25) * cos(angle);
      final startY = center.dy + (radius - 25) * sin(angle);
      final endX = center.dx + (radius - 15) * cos(angle);
      final endY = center.dy + (radius - 15) * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    const startAngle = -225.0;
    const sweepAngle = 270.0;

    final normalizedLevel = (level / 100).clamp(0.0, 1.0);
    final needleAngle =
        (startAngle + (sweepAngle * normalizedLevel)) * pi / 180;

    // Needle color based on spike
    final needleColor = isSpike ? AppColors.dustyRose : AppColors.lavenderWhite;

    // Draw needle shadow for spike effect
    if (isSpike) {
      final shadowPaint = Paint()
        ..color = AppColors.dustyRose.withValues(alpha: 0.5)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      final shadowEndX = center.dx + (radius - 40) * cos(needleAngle);
      final shadowEndY = center.dy + (radius - 40) * sin(needleAngle);

      canvas.drawLine(center, Offset(shadowEndX, shadowEndY), shadowPaint);
    }

    // Draw needle
    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final endX = center.dx + (radius - 40) * cos(needleAngle);
    final endY = center.dy + (radius - 40) * sin(needleAngle);

    canvas.drawLine(center, Offset(endX, endY), needlePaint);

    // Draw center pivot
    final pivotPaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, pivotPaint);

    // Draw outer pivot ring
    final pivotRingPaint = Paint()
      ..color = AppColors.twilightCard
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 8, pivotRingPaint);
  }

  @override
  bool shouldRepaint(EMFGaugePainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.isSpike != isSpike;
  }
}
