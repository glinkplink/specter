import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/commune_provider.dart';

class UserMessageBubble extends StatelessWidget {
  final Message message;

  const UserMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.ghostlyPurple.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: AppColors.ghostlyPurple.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: AppColors.boneWhite,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.1, end: 0, duration: 300.ms),
          ),
          const SizedBox(width: 12),

          // User avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.midGray.withOpacity(0.5),
              border: Border.all(
                color: AppColors.lightGray.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 20,
              color: AppColors.boneWhite.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
