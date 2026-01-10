import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/premium_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Subscription section
          _buildSettingsSection(
            context,
            'Subscription',
            [
              _buildSettingsTile(
                context,
                icon: premiumState.isPremium
                    ? Icons.workspace_premium
                    : Icons.lock,
                title: premiumState.isPremium
                    ? 'Premium Active'
                    : 'Upgrade to Premium',
                subtitle: premiumState.isPremium
                    ? 'Unlimited sessions and séances'
                    : 'Unlock all features',
                onTap: () => context.push('/paywall'),
                trailing: premiumState.isPremium
                    ? const Icon(Icons.check_circle,
                        color: AppColors.spectralGreen)
                    : null,
              ),
              if (premiumState.isPremium)
                _buildSettingsTile(
                  context,
                  icon: Icons.restore,
                  title: 'Restore Purchases',
                  subtitle: 'Sync your subscription',
                  onTap: () async {
                    final success = await ref
                        .read(premiumProvider.notifier)
                        .restorePurchases();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Purchases restored!'
                                : 'No purchases found',
                          ),
                          backgroundColor: success
                              ? AppColors.spectralGreen
                              : AppColors.zoneModerate,
                        ),
                      );
                    }
                  },
                ),
              // Debug mode toggle (web only)
              if (kIsWeb)
                _buildSettingsTile(
                  context,
                  icon: Icons.bug_report,
                  title: 'Debug Premium Mode',
                  subtitle: premiumState.debugModeEnabled
                      ? 'Enabled (for testing)'
                      : 'Disabled',
                  onTap: () =>
                      ref.read(premiumProvider.notifier).toggleDebugMode(),
                  trailing: Switch(
                    value: premiumState.debugModeEnabled,
                    onChanged: (_) =>
                        ref.read(premiumProvider.notifier).toggleDebugMode(),
                    activeColor: AppColors.spectralGreen,
                  ),
                ),
            ],
          ),

          _buildSettingsSection(
            context,
            'Detection',
            [
              _buildSettingsTile(
                context,
                icon: Icons.sensors,
                title: 'Sensitivity',
                subtitle: 'Adjust detection sensitivity',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.vibration,
                title: 'Haptic Feedback',
                subtitle: 'Enable vibration alerts',
                onTap: () {},
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Communication',
            [
              _buildSettingsTile(
                context,
                icon: Icons.smart_toy,
                title: 'AI Model',
                subtitle: 'Choose LLM for spirit communication',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.history,
                title: 'Chat History',
                subtitle: 'View past conversations',
                onTap: () {},
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Appearance',
            [
              _buildSettingsTile(
                context,
                icon: Icons.dark_mode,
                title: 'Theme',
                subtitle: 'Dark mode (Ghost mode enabled)',
                onTap: () {},
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'About',
            [
              _buildSettingsTile(
                context,
                icon: Icons.info,
                title: 'Version',
                subtitle: '1.0.0 - Sprint 5',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.spectralGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.ghostlyPurple,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.lightGray,
            ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: AppColors.lightGray,
          ),
      onTap: onTap,
    );
  }
}
