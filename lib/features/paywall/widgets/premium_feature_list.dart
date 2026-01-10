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
          title: 'Unlimited Sessions',
          description: 'Connect with spirits without limits',
        ),
        const SizedBox(height: 16),
        _buildFeature(
          icon: Icons.mic,
          title: 'Unlimited Séances',
          description: 'Use audio recording for deeper communication',
        ),
        const SizedBox(height: 16),
        _buildFeature(
          icon: Icons.access_time,
          title: 'Extended Sessions',
          description: 'Longer conversations without time limits',
        ),
        const SizedBox(height: 16),
        _buildFeature(
          icon: Icons.support,
          title: 'Priority Support',
          description: 'Get help from the beyond, faster',
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
            color: AppColors.spectralGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.spectralGreen,
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
                  color: AppColors.boneWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.boneWhite.withOpacity(0.7),
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
