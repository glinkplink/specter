import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/premium_provider.dart';
import 'widgets/premium_feature_list.dart';
import 'widgets/subscription_card.dart';
import 'models/subscription_option.dart' as models;

/// Paywall screen for subscription purchases
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Package? _selectedPackage;

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumProvider);

    // If already premium, go back
    if (premiumState.isPremium) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.canPop()) {
          context.pop();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.deepVoid,
      body: SafeArea(
        child: premiumState.isLoading && premiumState.offerings == null
            ? _buildLoadingState()
            : premiumState.offerings == null
                ? _buildErrorState()
                : _buildPaywallContent(premiumState),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.amethystGlow),
          ),
          SizedBox(height: 16),
          Text(
            'Preparing the veil...',
            style: TextStyle(color: AppColors.lavenderWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.zoneActive,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load subscription options',
              style: TextStyle(
                color: AppColors.lavenderWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                color: AppColors.lavenderWhite.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amethystGlow,
                foregroundColor: AppColors.deepVoid,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaywallContent(PremiumState premiumState) {
    final offering = premiumState.offerings!.current;
    if (offering == null || offering.availablePackages.isEmpty) {
      return _buildErrorState();
    }

    final subscriptionOptions = offering.availablePackages
        .map((pkg) => models.SubscriptionOption.fromPackage(pkg))
        .toList();

    // Auto-select annual package if available, otherwise first package
    if (_selectedPackage == null && subscriptionOptions.isNotEmpty) {
      _selectedPackage = subscriptionOptions
          .firstWhere(
            (opt) => opt.isPopular,
            orElse: () => subscriptionOptions.first,
          )
          .package;
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Header
              const Icon(
                Icons.auto_awesome,
                color: AppColors.mysticGold,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unlock the Veil',
                style: TextStyle(
                  color: AppColors.lavenderWhite,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Commune without limits. The spirits await.',
                style: TextStyle(
                  color: AppColors.mutedLavender.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Features
              const PremiumFeatureList(),
              const SizedBox(height: 32),

              // Subscription options
              const Text(
                'Choose Your Path',
                style: TextStyle(
                  color: AppColors.lavenderWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ...subscriptionOptions.map(
                (option) => SubscriptionCard(
                  option: option,
                  isSelected:
                      _selectedPackage?.identifier == option.package.identifier,
                  onTap: () =>
                      setState(() => _selectedPackage = option.package),
                ),
              ),

              const SizedBox(height: 24),

              // Purchase button
              ElevatedButton(
                onPressed: premiumState.isLoading ? null : _handlePurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mysticGold,
                  foregroundColor: AppColors.deepVoid,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: AppColors.dimLavender,
                ),
                child: premiumState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.deepVoid),
                        ),
                      )
                    : const Text(
                        'Open the Veil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Restore purchases
              TextButton(
                onPressed: premiumState.isLoading ? null : _handleRestore,
                child: const Text(
                  'Restore Purchases',
                  style: TextStyle(
                    color: AppColors.amethystGlow,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Terms
              Text(
                'Subscription auto-renews unless cancelled. Terms and privacy policy apply.',
                style: TextStyle(
                  color: AppColors.dimLavender.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 80), // Space for close button
            ],
          ),
        ),

        // Close button
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.close,
              color: AppColors.mutedLavender,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    final success = await ref
        .read(premiumProvider.notifier)
        .purchasePackage(_selectedPackage!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The veil opens for you...'),
          backgroundColor: AppColors.amethystGlow,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(premiumProvider).error;
      if (error != null && !error.toLowerCase().contains('cancel')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.zoneActive,
          ),
        );
      }
    }
  }

  Future<void> _handleRestore() async {
    final success = await ref.read(premiumProvider.notifier).restorePurchases();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Purchases restored successfully!'
              : 'No purchases found to restore',
        ),
        backgroundColor:
            success ? AppColors.amethystGlow : AppColors.zoneModerate,
      ),
    );

    if (success) {
      context.pop();
    }
  }
}
