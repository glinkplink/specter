import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/daily_veil_card.dart';
import 'widgets/rotating_moon.dart';

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
      body: Stack(
        children: [
          // Gradient background
          Container(
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
          ),
          
          // Floating particles
          ...List.generate(15, (index) => _buildFloatingParticle(index)),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Large animated moon with enhanced glow
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.amethystGlow.withOpacity(0.4),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                          BoxShadow(
                            color: AppColors.dustyRose.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: _buildLargeMoon(),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.05, 1.05),
                          duration: 4.seconds,
                          curve: Curves.easeInOut,
                        ),

                    const SizedBox(height: 32),

                    Text(
                      'What Lies Beyond?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.lavenderWhite,
                            letterSpacing: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .shimmer(delay: 1.seconds, duration: 2.seconds),

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

                    // Daily Veil Card
                    const DailyVeilCard(),

                    const SizedBox(height: 24),

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

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Large moon widget using the RotatingMoon
  Widget _buildLargeMoon() {
    final now = DateTime.now();
    final daysSinceNewMoon = (now.millisecondsSinceEpoch / 86400000) % 29.53;
    final phase = daysSinceNewMoon / 29.53;
    
    return RotatingMoon(
      phase: phase,
      size: 140,
    );
  }

  // Floating particle effect
  Widget _buildFloatingParticle(int index) {
    final random = Random(index);
    final size = 2.0 + random.nextDouble() * 4;
    final duration = 8 + random.nextInt(15);
    final delay = random.nextInt(5);
    
    return Positioned.fill(
      child: Align(
        alignment: Alignment(
          random.nextDouble() * 2 - 1, // -1 to 1 (left to right)
          random.nextDouble() * 2 - 1, // -1 to 1 (top to bottom)
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.amethystGlow.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: AppColors.amethystGlow.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: -20,
              end: 20,
              duration: Duration(seconds: duration),
              delay: Duration(seconds: delay),
              curve: Curves.easeInOut,
            )
            .fadeIn(duration: 2.seconds)
            .then()
            .fadeOut(duration: 2.seconds),
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
