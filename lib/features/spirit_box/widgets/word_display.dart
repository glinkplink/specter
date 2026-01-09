import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class WordDisplay extends StatelessWidget {
  final String? currentWord;
  final List<String> wordHistory;
  final bool isScanning;

  const WordDisplay({
    super.key,
    this.currentWord,
    required this.wordHistory,
    required this.isScanning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main word display area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.deepBlack.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: currentWord != null
                    ? AppColors.spectralGreen.withOpacity(0.5)
                    : AppColors.lightGray.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: currentWord != null
                  ? [
                      BoxShadow(
                        color: AppColors.spectralGreen.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: _buildMainWord(),
          ),

          const SizedBox(height: 16),

          // Word history (ghost trail)
          if (wordHistory.isNotEmpty && wordHistory.length > 1)
            _buildWordHistory(),
        ],
      ),
    );
  }

  Widget _buildMainWord() {
    if (currentWord == null) {
      return Text(
        isScanning ? '...' : 'READY',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.boneWhite.withOpacity(0.3),
          letterSpacing: 4,
        ),
      );
    }

    return Text(
      currentWord!.toUpperCase(),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: AppColors.spectralGreen,
        letterSpacing: 2,
        height: 1.2,
      ),
    )
        .animate()
        .fadeIn(duration: 100.ms, curve: Curves.easeIn)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .then()
        .shimmer(
          duration: 400.ms,
          color: AppColors.spectralGreen.withOpacity(0.5),
        );
  }

  Widget _buildWordHistory() {
    // Skip the first word (current word) and show the rest
    final historyToShow = wordHistory.skip(1).take(4).toList();

    return Column(
      children: [
        Text(
          'RECENT ACTIVITY',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.boneWhite.withOpacity(0.4),
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...historyToShow.asMap().entries.map((entry) {
          final index = entry.key;
          final word = entry.value;
          final opacity = 0.5 - (index * 0.1);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              word.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20 - (index * 3),
                color: AppColors.spectralGreen.withOpacity(opacity.clamp(0.1, 1.0)),
                letterSpacing: 1,
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms),
          );
        }),
      ],
    );
  }
}
