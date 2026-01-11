import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SignalBars extends StatefulWidget {
  final bool isScanning;
  final double intensity;

  const SignalBars({
    super.key,
    required this.isScanning,
    required this.intensity,
  });

  @override
  State<SignalBars> createState() => _SignalBarsState();
}

class _SignalBarsState extends State<SignalBars> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    if (widget.isScanning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SignalBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _controller.repeat();
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _controller.stop();
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
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              20,
              (index) => _buildBar(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBar(int index) {
    if (!widget.isScanning) {
      return Container(
        width: 4,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.shadeMist.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    // Calculate bar height with randomness
    final baseHeight = widget.intensity * 80;
    final randomFactor = _random.nextDouble();
    final height = (baseHeight * (0.3 + randomFactor * 0.7)).clamp(10.0, 80.0);

    // Color based on intensity - use dusty rose for high intensity
    final color = widget.intensity > 0.6
        ? AppColors.dustyRose
        : AppColors.amethystGlow.withOpacity(0.6);

    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        boxShadow: widget.intensity > 0.6
            ? [
                BoxShadow(
                  color: AppColors.dustyRose.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
