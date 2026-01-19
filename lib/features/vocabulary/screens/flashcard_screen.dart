import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

/// Flashcard study screen with real data from database
class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  List<VocabularyWord> _queue = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _knownCount = 0;
  int _learningCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    final words = await ref.read(dueVocabularyProvider.future);
    if (mounted) {
      setState(() {
        _queue = List.from(words)..shuffle();
        _isLoading = false;
      });
    }
  }

  VocabularyWord get _currentWord => _queue[_currentIndex];
  bool get _isComplete => _currentIndex >= _queue.length;

  void _flipCard() {
    setState(() => _isFlipped = !_isFlipped);
  }

  Future<void> _reviewWord(bool known) async {
    final word = _currentWord;
    final db = ref.read(databaseProvider);
    
    // Simple SRS Algorithm
    // This is a basic version of SM-2
    double newEaseFactor = word.easeFactor;
    int newInterval = word.intervalDays;
    
    if (known) {
      if (word.reviewCount == 0) {
        newInterval = 1;
      } else if (word.reviewCount == 1) {
        newInterval = 6;
      } else {
        newInterval = (newInterval * newEaseFactor).round();
      }
      _knownCount++;
    } else {
      newInterval = 1;
      newEaseFactor = max(1.3, newEaseFactor - 0.2);
      _learningCount++;
    }

    final nextReview = DateTime.now().add(Duration(days: newInterval));

    await db.upsertVocabularyWord(VocabularyWordsCompanion(
      id: drift.Value(word.id),
      reviewCount: drift.Value(word.reviewCount + 1),
      correctCount: drift.Value(known ? word.correctCount + 1 : word.correctCount),
      easeFactor: drift.Value(newEaseFactor),
      intervalDays: drift.Value(newInterval),
      lastReviewedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      nextReviewAt: drift.Value(nextReview.millisecondsSinceEpoch),
    ));

    setState(() {
      _isFlipped = false;
      _currentIndex++;
    });
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _knownCount = 0;
      _learningCount = 0;
      _queue.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Flashcards'),
        centerTitle: true,
        actions: [
          if (!_isComplete && _queue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1}/${_queue.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _queue.isEmpty
          ? _EmptyState()
          : _isComplete
              ? _CompletionState(
                  total: _queue.length,
                  known: _knownCount,
                  learning: _learningCount,
                  onRestart: _restart,
                  onClose: () => Navigator.pop(context),
                )
              : Column(
                  children: [
                    // Progress bar
                    LinearProgressIndicator(
                      value: _currentIndex / _queue.length,
                      backgroundColor: AppColors.divider,
                      color: AppColors.accent,
                      minHeight: 3,
                    ),

                    // Card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        child: GestureDetector(
                          onTap: _flipCard,
                          child: _FlipCard(
                            word: _currentWord,
                            isFlipped: _isFlipped,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),

                    // Hint
                    if (!_isFlipped)
                      Text(
                        'Tap card to reveal definition',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ).animate().fadeIn(),

                    const SizedBox(height: AppTheme.spacingM),

                    // Action buttons
                    if (_isFlipped)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spacingL,
                          0,
                          AppTheme.spacingL,
                          AppTheme.spacingL,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.refresh_rounded,
                                label: 'Still Learning',
                                color: AppColors.warning,
                                onTap: () => _reviewWord(false),
                              ).animate().fadeIn().slideX(begin: -0.1),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.check_rounded,
                                label: 'Got It',
                                color: AppColors.success,
                                onTap: () => _reviewWord(true),
                              ).animate().fadeIn().slideX(begin: 0.1),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(height: 80 + MediaQuery.of(context).padding.bottom),

                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  final VocabularyWord word;
  final bool isFlipped;
  final bool isDark;

  const _FlipCard({
    required this.word,
    required this.isFlipped,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          builder: (context, _) {
            final isBack = rotate.value > pi / 2;
            return Transform(
              transform: Matrix4.rotationY(isBack ? pi : 0),
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      child: isFlipped
          ? _BackCard(key: const ValueKey('back'), word: word, isDark: isDark)
          : _FrontCard(key: const ValueKey('front'), word: word, isDark: isDark),
    );
  }
}

class _FrontCard extends StatelessWidget {
  final VocabularyWord word;
  final bool isDark;

  const _FrontCard({super.key, required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowMedium,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            word.word,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          if (word.phonetic != null) ...[
            const SizedBox(height: 12),
            Text(
              '/${word.phonetic}/',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (word.partOfSpeech != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word.partOfSpeech!,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    word.contextSentence,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  final VocabularyWord word;
  final bool isDark;

  const _BackCard({super.key, required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowMedium,
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            word.word,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'DEFINITION',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.definition ?? 'No definition available',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (word.example != null) ...[
            Text(
              'EXAMPLE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${word.example}"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No flashcards due',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Great job! You have reviewed all scheduled words for now.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionState extends StatelessWidget {
  final int total;
  final int known;
  final int learning;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  const _CompletionState({
    required this.total,
    required this.known,
    required this.learning,
    required this.onRestart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (known / total * 100).round();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                size: 64,
                color: AppColors.success,
              ),
            ).animate().scale(),
            const SizedBox(height: 24),
            Text(
              'Session Complete!',
              style: Theme.of(context).textTheme.headlineMedium,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'You reviewed $total words',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatItem(
                  icon: Icons.check_circle_rounded,
                  value: '$known',
                  label: 'Known',
                  color: AppColors.success,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(width: 32),
                _StatItem(
                  icon: Icons.refresh_rounded,
                  value: '$learning',
                  label: 'Learning',
                  color: AppColors.warning,
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '$percentage% accuracy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    child: const Text('Done'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRestart,
                    child: const Text('Study Again'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
