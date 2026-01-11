import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget displaying the list of premium features
class PremiumFeatureList extends StatelessWidget {
  const PremiumFeatureList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFeature(
          icon: Icons.all_inclusive,
          title: 'Unlimited Communion',
          description: 'Speak with spirits without limits',
        ),
        const SizedBox(height: 16),
        _buildFeature(
          icon: Icons.mic,
          title: 'Unlimited Séances',
          description: 'Let your voice reach across the veil',
        ),
        const SizedBox(height: 16),
        _buildFeature(
          icon: Icons.access_time,
          title: 'Extended Sessions',
          description: 'Longer conversations, deeper connections',
        ),
        const SizedBox(height: 16),
        _buildFeature(
          icon: Icons.support,
          title: 'Priority Connection',
          description: 'The spirits hear you first',
        ),
      ],
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.amethystGlow.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.amethystGlow,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.lavenderWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.mutedLavender.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
