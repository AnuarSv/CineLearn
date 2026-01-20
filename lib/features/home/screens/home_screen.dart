import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

/// Home screen with overview and quick actions
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentVideosAsync = ref.watch(recentVideosProvider);
    final vocabularyCountAsync = ref.watch(vocabularyCountProvider);
    
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
                      'CineLearn',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Learn English through movies',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                  ],
                ),
              ),
            ),
            
            // Stats cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Row(
                  children: [
                    Expanded(
                      child: vocabularyCountAsync.when(
                        data: (count) => _StatCard(
                          icon: Icons.menu_book_rounded,
                          value: '$count',
                          label: 'Words Saved',
                          color: AppColors.accent,
                          isDark: isDark,
                        ),
                        loading: () => _StatCard(
                          icon: Icons.menu_book_rounded,
                          value: '-',
                          label: 'Words Saved',
                          color: AppColors.accent,
                          isDark: isDark,
                        ),
                        error: (_, __) => _StatCard(
                          icon: Icons.menu_book_rounded,
                          value: '!',
                          label: 'Words Saved',
                          color: AppColors.accent,
                          isDark: isDark,
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        value: '0',
                        label: 'Day Streak',
                        color: AppColors.warning,
                        isDark: isDark,
                      ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingL)),
            
            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 400.ms),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingM)),
            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppTheme.spacingM,
                  crossAxisSpacing: AppTheme.spacingM,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _ActionCard(
                    icon: Icons.add_rounded,
                    title: 'Add Video',
                    subtitle: 'Import a movie or series',
                    color: AppColors.accent,
                    onTap: () => context.go('/library'),
                    isDark: isDark,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  _ActionCard(
                    icon: Icons.play_circle_filled_rounded,
                    title: 'Review',
                    subtitle: 'Practice saved words',
                    color: AppColors.success,
                    onTap: () => context.go('/reels'),
                    isDark: isDark,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  _ActionCard(
                    icon: Icons.style_rounded,
                    title: 'Flashcards',
                    subtitle: 'Study vocabulary',
                    color: AppColors.warning,
                    onTap: () => context.go('/flashcards'),
                    isDark: isDark,
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                  _ActionCard(
                    icon: Icons.sports_esports_rounded,
                    title: 'Games',
                    subtitle: 'Learn with games',
                    color: AppColors.error,
                    onTap: () => context.go('/games'),
                    isDark: isDark,
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                ]),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingXL)),
            
            // Recent activity section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Text(
                  'Continue Watching',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 900.ms),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingM)),
            
            recentVideosAsync.when(
              data: (videos) {
                if (videos.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingXL),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.movie_outlined,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              'No videos yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            Text(
                              'Add your first movie to start learning',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 1000.ms),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final video = videos[index];
                        return _RecentVideoItem(
                          video: video,
                          isDark: isDark,
                          onTap: () => context.go('/player/${video.id}'),
                        );
                      },
                      childCount: videos.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _RecentVideoItem extends StatelessWidget {
  final Video video;
  final bool isDark;
  final VoidCallback onTap;

  const _RecentVideoItem({
    required this.video,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = video.durationMs > 0 ? video.lastPositionMs / video.durationMs : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.shadowSmall,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.play_circle_outline, color: AppColors.textTertiary),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.black12,
                      color: AppColors.accent,
                      minHeight: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
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
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
