import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/commune_provider.dart';

class SpiritMessageBubble extends StatefulWidget {
  final Message message;
  final bool isLatest;

  const SpiritMessageBubble({
    super.key,
    required this.message,
    this.isLatest = false,
  });

  @override
  State<SpiritMessageBubble> createState() => _SpiritMessageBubbleState();
}

class _SpiritMessageBubbleState extends State<SpiritMessageBubble> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _typingTimer;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLatest) {
      // Materialize letter by letter for the latest message
      _startMaterialization();
    } else {
      // Show full text for older messages
      _displayedText = widget.message.content;
      _isComplete = true;
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startMaterialization() {
    // Initial delay for atmosphere
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      _typingTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
        if (_currentIndex < widget.message.content.length) {
          setState(() {
            _displayedText = widget.message.content.substring(0, _currentIndex + 1);
            _currentIndex++;
          });
        } else {
          timer.cancel();
          setState(() {
            _isComplete = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spirit avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.ghostlyPurple.withOpacity(0.6),
                  AppColors.ghostlyPurple.withOpacity(0.2),
                ],
              ),
            ),
            child: Icon(
              widget.message.isSeanceResponse ? Icons.hearing : Icons.auto_awesome,
              size: 18,
              color: AppColors.boneWhite.withOpacity(0.8),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 2.seconds,
              ),
          const SizedBox(width: 12),

          // Message bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.midGray.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: AppColors.ghostlyPurple.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ghostlyPurple.withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Séance indicator
                  if (widget.message.isSeanceResponse) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.graphic_eq,
                          size: 12,
                          color: AppColors.ghostlyPurple.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'FROM THE STATIC',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: AppColors.ghostlyPurple.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Message text with materialization effect
                  _buildMessageText(),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.1, end: 0, duration: 400.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageText() {
    if (!widget.isLatest || _isComplete) {
      // Static glow effect for complete messages
      return Text(
        widget.message.content,
        style: TextStyle(
          color: AppColors.boneWhite.withOpacity(0.9),
          fontSize: 16,
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Materializing text with cursor
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: _displayedText,
            style: TextStyle(
              color: AppColors.boneWhite.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          // Blinking cursor
          WidgetSpan(
            child: Container(
              width: 2,
              height: 18,
              margin: const EdgeInsets.only(left: 2),
              color: AppColors.ghostlyPurple,
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 400.ms)
                .then()
                .fadeOut(duration: 400.ms),
          ),
        ],
      ),
    );
  }
}
