import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/subscription_option.dart';

/// Card widget for displaying a subscription option
class SubscriptionCard extends StatelessWidget {
  final SubscriptionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.midGray : AppColors.darkGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.spectralGreen
                : AppColors.lightGray.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Radio indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.spectralGreen
                            : AppColors.lightGray,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.spectralGreen,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Plan details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.package.storeProduct.title
                              .split('(')
                              .first
                              .trim(),
                          style: const TextStyle(
                            color: AppColors.boneWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (option.isBestValue)
                          Text(
                            option.pricePerMonth,
                            style: const TextStyle(
                              color: AppColors.spectralGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Price
                  Text(
                    option.price,
                    style: const TextStyle(
                      color: AppColors.boneWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Popular badge
            if (option.isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.spectralGreen,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: AppColors.deepBlack,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
