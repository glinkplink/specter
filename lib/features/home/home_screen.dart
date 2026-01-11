import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPECTER'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.deepVoid,
              AppColors.darkPlum.withOpacity(0.8),
              AppColors.deepVoid,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mystical icon with glow
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.amethystGlow.withOpacity(0.3),
                          AppColors.plumVeil.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.amethystGlow.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.wb_twilight,
                      size: 64,
                      color: AppColors.amethystGlow,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.05, 1.05),
                        duration: 3.seconds,
                        curve: Curves.easeInOut,
                      ),

                  const SizedBox(height: 40),

                  Text(
                    'What Lies Beyond?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.lavenderWhite,
                          letterSpacing: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 200.ms),

                  const SizedBox(height: 16),

                  Text(
                    'Sense the unseen. Listen to whispers.\nSpeak across the veil.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedLavender,
                          height: 1.6,
                        ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 400.ms),

                  const SizedBox(height: 48),

                  // Feature cards
                  _buildFeatureCard(
                    context,
                    icon: Icons.sensors,
                    title: 'Sense',
                    subtitle: 'Detect energy anomalies',
                    onTap: () => context.go('/scan'),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.graphic_eq,
                    title: 'Listen',
                    subtitle: 'Hear fragments from beyond',
                    onTap: () => context.go('/spirit-box'),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 750.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.auto_awesome,
                    title: 'Commune',
                    subtitle: 'Speak with those who linger',
                    onTap: () => context.go('/commune'),
                    isPremium: true,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 900.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.twilightCard.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPremium
                  ? AppColors.mysticGold.withOpacity(0.3)
                  : AppColors.amethystGlow.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: (isPremium ? AppColors.mysticGold : AppColors.amethystGlow)
                    .withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isPremium ? AppColors.mysticGold : AppColors.amethystGlow)
                      .withOpacity(0.2),
                ),
                child: Icon(
                  icon,
                  color: isPremium ? AppColors.mysticGold : AppColors.amethystGlow,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColors.lavenderWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mysticGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: AppColors.mysticGold,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.mutedLavender,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.dimLavender,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
