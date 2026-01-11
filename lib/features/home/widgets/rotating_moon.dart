import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Static hyper-realistic moon using high-quality PNG image
class RotatingMoon extends StatelessWidget {
  final double phase;
  final double size;

  const RotatingMoon({
    super.key,
    required this.phase,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.amethystGlow.withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: AppColors.dustyRose.withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/moon.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
