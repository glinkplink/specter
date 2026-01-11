import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/premium_provider.dart';
import '../../core/providers/haptic_provider.dart';
import '../../shared/widgets/specter_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: SpecterBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            _buildSettingsSection(
              context,
              'Subscription',
              [
                _buildSettingsTile(
                  context,
                  icon: premiumState.isPremium
                      ? Icons.workspace_premium
                      : Icons.lock,
                  title: premiumState.isPremium ? 'Premium Active' : 'Upgrade',
                  subtitle: premiumState.isPremium
                      ? 'Unlimited sessions and séances'
                      : 'Unlock all features',
                  onTap: () => context.push('/paywall'),
                  trailing: premiumState.isPremium
                      ? const Icon(Icons.check_circle,
                          color: AppColors.mysticGold)
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
                                ? AppColors.amethystGlow
                                : AppColors.zoneModerate,
                          ),
                        );
                      }
                    },
                  ),
                if (kIsWeb)
                  _buildSettingsTile(
                    context,
                    icon: Icons.bug_report,
                    title: 'Debug Premium Mode',
                    subtitle: premiumState.debugModeEnabled
                        ? 'Enabled (testing)'
                        : 'Disabled',
                    onTap: () =>
                        ref.read(premiumProvider.notifier).toggleDebugMode(),
                    trailing: Switch(
                      value: premiumState.debugModeEnabled,
                      onChanged: (_) =>
                          ref.read(premiumProvider.notifier).toggleDebugMode(),
                      activeThumbColor: AppColors.amethystGlow,
                      activeTrackColor:
                          AppColors.amethystGlow.withValues(alpha: 0.3),
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
                  icon: Icons.vibration,
                  title: 'Haptic Feedback',
                  subtitle: ref.watch(hapticProvider).displayName,
                  onTap: () => _showHapticDialog(context, ref),
                ),
              ],
            ),
            _buildSettingsSection(
              context,
              'Communication',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.history,
                  title: 'Chat History',
                  subtitle: 'Coming soon',
                  onTap: null,
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
                  subtitle: '1.0.0',
                  onTap: null,
                ),
              ],
            ),
          ],
        ),
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
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.amethystGlow,
                  letterSpacing: 1.8,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.twilightCard.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.amethystGlow.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepVoid.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 20),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      enabled: onTap != null,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.amethystGlow.withValues(alpha: 0.14),
          border: Border.all(
            color: AppColors.amethystGlow.withValues(alpha: 0.25),
          ),
        ),
        child: Icon(icon, color: AppColors.amethystGlow, size: 18),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.lavenderWhite,
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mutedLavender.withValues(alpha: 0.9),
            ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: onTap == null
                ? AppColors.dimLavender.withValues(alpha: 0.35)
                : AppColors.dimLavender,
          ),
      onTap: onTap,
    );
  }

  void _showHapticDialog(BuildContext context, WidgetRef ref) {
    final currentLevel = ref.read(hapticProvider).level;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkPlum,
        title: Text(
          'Haptic Feedback',
          style: TextStyle(color: AppColors.lavenderWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHapticOption(
              context,
              ref,
              HapticLevel.low,
              'Low',
              currentLevel == HapticLevel.low,
            ),
            const SizedBox(height: 8),
            _buildHapticOption(
              context,
              ref,
              HapticLevel.medium,
              'Medium',
              currentLevel == HapticLevel.medium,
            ),
            const SizedBox(height: 8),
            _buildHapticOption(
              context,
              ref,
              HapticLevel.high,
              'High',
              currentLevel == HapticLevel.high,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHapticOption(
    BuildContext context,
    WidgetRef ref,
    HapticLevel level,
    String label,
    bool isSelected,
  ) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.amethystGlow : AppColors.lavenderWhite,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing:
          isSelected ? Icon(Icons.check, color: AppColors.amethystGlow) : null,
      onTap: () {
        ref.read(hapticProvider.notifier).setLevel(level);
        Navigator.of(context).pop();
      },
    );
  }
}
