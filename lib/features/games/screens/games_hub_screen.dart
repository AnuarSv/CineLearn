import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';

/// Games hub screen with various vocabulary games
class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Games',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 8),
                    Text(
                      'Practice vocabulary with interactive games',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
              ),
            ),

            // Games grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppTheme.spacingM,
                  crossAxisSpacing: AppTheme.spacingM,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _GameCard(
                    icon: Icons.hearing_rounded,
                    title: 'Listening Quiz',
                    description: 'Identify words you hear',
                    color: AppColors.accent,
                    wordsCount: 0,
                    isDark: isDark,
                    onTap: () => _showComingSoon(context),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  _GameCard(
                    icon: Icons.extension_rounded,
                    title: 'Word Puzzle',
                    description: 'Arrange letters correctly',
                    color: AppColors.success,
                    wordsCount: 0,
                    isDark: isDark,
                    onTap: () => _showComingSoon(context),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  _GameCard(
                    icon: Icons.edit_rounded,
                    title: 'Fill the Blank',
                    description: 'Complete sentences',
                    color: AppColors.warning,
                    wordsCount: 0,
                    isDark: isDark,
                    onTap: () => _showComingSoon(context),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  _GameCard(
                    icon: Icons.compare_arrows_rounded,
                    title: 'Match Game',
                    description: 'Match words to definitions',
                    color: AppColors.error,
                    wordsCount: 0,
                    isDark: isDark,
                    onTap: () => _showComingSoon(context),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingXL)),

            // Daily challenge section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenge',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: AppTheme.spacingM),
                    _DailyChallengeCard(isDark: isDark)
                        .animate()
                        .fadeIn(delay: 700.ms),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingXL)),

            // Stats section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Stats',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 800.ms),
                    const SizedBox(height: AppTheme.spacingM),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.games_rounded,
                            value: '0',
                            label: 'Games Played',
                            isDark: isDark,
                          ).animate().fadeIn(delay: 900.ms),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle_rounded,
                            value: '0%',
                            label: 'Accuracy',
                            isDark: isDark,
                          ).animate().fadeIn(delay: 1000.ms),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Save some words first to play games!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final int wordsCount;
  final bool isDark;
  final VoidCallback onTap;

  const _GameCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.wordsCount,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = wordsCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.shadowSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$wordsCount words',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final bool isDark;

  const _DailyChallengeCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.accentLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete Daily Challenge',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Practice 10 words to maintain your streak',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
