import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
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
                subtitle: '1.0.0 - Sprint 1',
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
    required VoidCallback onTap,
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
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.lightGray,
      ),
      onTap: onTap,
    );
  }
}
