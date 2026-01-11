import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Shooting star with a fading trail
class ShootingStar extends StatefulWidget {
  final int index;
  
  const ShootingStar({super.key, required this.index});

  @override
  State<ShootingStar> createState() => _ShootingStarState();
}

class _ShootingStarState extends State<ShootingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  late double _startX;
  late double _startY;
  late double _angle;
  late double _delay;
  late double _speed;
  
  final Random _random = Random();
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _randomizeTrajectory();
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (2000 / _speed).round()),
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    // Start after random delay
    Future.delayed(Duration(seconds: _delay.round()), () {
      if (mounted) {
        _startAnimation();
      }
    });
  }

  void _randomizeTrajectory() {
    // Seed with index for variety
    final seed = Random(widget.index + DateTime.now().millisecondsSinceEpoch ~/ 10000);
    
    _startX = seed.nextDouble() * 0.8 + 0.1; // 10-90% of screen width
    _startY = seed.nextDouble() * 0.25; // Top 25% of screen
    _angle = 0.4 + seed.nextDouble() * 0.6; // Diagonal angle (radians)
    _delay = 15.0 + seed.nextDouble() * 25.0; // 15-40 second delay (much less frequent)
    _speed = 1.0 + seed.nextDouble() * 0.5; // Speed multiplier
  }

  void _startAnimation() {
    if (!mounted) return;
    
    setState(() {
      _isVisible = true;
    });
    
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        _controller.reset();
        _randomizeTrajectory();
        
        // Schedule next shooting star
        Future.delayed(Duration(seconds: _delay.round()), () {
          if (mounted) {
            _startAnimation();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        
        final startPosX = _startX * screenWidth;
        final startPosY = _startY * screenHeight;
        final travelDistance = screenWidth * 1.2;
        
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final progress = _animation.value;
            
            // Current head position
            final currentX = startPosX + cos(_angle) * travelDistance * progress;
            final currentY = startPosY + sin(_angle) * travelDistance * progress;
            
            return CustomPaint(
              size: Size(screenWidth, screenHeight),
              painter: ShootingStarPainter(
                headX: currentX,
                headY: currentY,
                angle: _angle,
                progress: progress,
                trailLength: 40, // Much smaller - similar to star size
              ),
            );
          },
        );
      },
    );
  }
}

/// Custom painter for shooting star with fading trail
class ShootingStarPainter extends CustomPainter {
  final double headX;
  final double headY;
  final double angle;
  final double progress;
  final double trailLength;

  ShootingStarPainter({
    required this.headX,
    required this.headY,
    required this.angle,
    required this.progress,
    required this.trailLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate trail start (behind the head)
    final trailStartX = headX - cos(angle) * trailLength;
    final trailStartY = headY - sin(angle) * trailLength;
    
    // Create gradient for trail (bright at head, fading to transparent)
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        AppColors.lavenderWhite.withOpacity(0.2),
        AppColors.lavenderWhite.withOpacity(0.6),
        AppColors.lavenderWhite.withOpacity(0.95),
        Colors.white,
      ],
      stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
    );

    // Draw the trail as a tapered line
    final path = Path();
    
    // Trail thickness tapers from thin to thick (small like stars)
    const headWidth = 1.5;
    const tailWidth = 0.3;
    
    // Calculate perpendicular offset for width
    final perpX = sin(angle);
    final perpY = -cos(angle);
    
    // Build tapered trail shape
    path.moveTo(
      trailStartX + perpX * tailWidth,
      trailStartY + perpY * tailWidth,
    );
    path.lineTo(
      headX + perpX * headWidth,
      headY + perpY * headWidth,
    );
    path.lineTo(
      headX - perpX * headWidth,
      headY - perpY * headWidth,
    );
    path.lineTo(
      trailStartX - perpX * tailWidth,
      trailStartY - perpY * tailWidth,
    );
    path.close();

    // Create shader for the gradient along the trail
    final rect = Rect.fromPoints(
      Offset(trailStartX, trailStartY),
      Offset(headX, headY),
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);
    
    // Draw bright head glow (small like stars)
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(headX, headY), 1.5, glowPaint);
    
    // Draw core head
    final headPaint = Paint()
      ..color = Colors.white;
    canvas.drawCircle(Offset(headX, headY), 1, headPaint);
  }

  @override
  bool shouldRepaint(ShootingStarPainter oldDelegate) {
    return oldDelegate.headX != headX || 
           oldDelegate.headY != headY ||
           oldDelegate.progress != progress;
  }
}
