import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class SeanceRecorder extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const SeanceRecorder({
    super.key,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<SeanceRecorder> createState() => _SeanceRecorderState();
}

class _SeanceRecorderState extends State<SeanceRecorder> {
  static const int _recordDuration = 12; // seconds
  int _remainingSeconds = _recordDuration;
  Timer? _countdownTimer;
  Timer? _waveformTimer;
  final List<double> _waveformData = List.filled(30, 0.2);
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _waveformTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        widget.onComplete();
      }
    });

    // Waveform animation
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        for (int i = 0; i < _waveformData.length; i++) {
          // Simulate audio waveform with random fluctuations
          _waveformData[i] = 0.1 + (_random.nextDouble() * 0.8);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkPlum,
        border: Border(
          top: BorderSide(
            color: AppColors.amethystGlow.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Recording indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.dustyRose,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(duration: 500.ms)
                      .then()
                      .fadeOut(duration: 500.ms),
                  const SizedBox(width: 12),
                  Text(
                    'SÉANCE',
                    style: TextStyle(
                      color: AppColors.lavenderWhite,
                      fontSize: 14,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Cancel button
              IconButton(
                onPressed: widget.onCancel,
                icon: Icon(
                  Icons.close,
                  color: AppColors.dimLavender,
                ),
                tooltip: 'Cancel',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Waveform visualization
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _waveformData.map((height) {
                return Container(
                  width: 4,
                  height: 60 * height,
                  decoration: BoxDecoration(
                    color: AppColors.dustyRose.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Instructions
          Text(
            'Listening to the silence...',
            style: TextStyle(
              color: AppColors.lavenderWhite.withValues(alpha: 0.8),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'The spirits find meaning in the static',
            style: TextStyle(
              color: AppColors.amethystGlow.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          // Countdown and progress
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 1 - (_remainingSeconds / _recordDuration),
                  strokeWidth: 4,
                  backgroundColor:
                      AppColors.twilightCard.withValues(alpha: 0.4),
                  valueColor: AlwaysStoppedAnimation(AppColors.amethystGlow),
                ),
              ),
              // Countdown text
              Column(
                children: [
                  Text(
                    '$_remainingSeconds',
                    style: TextStyle(
                      color: AppColors.lavenderWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'sec',
                    style: TextStyle(
                      color: AppColors.dimLavender,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 300.ms);
  }
}
