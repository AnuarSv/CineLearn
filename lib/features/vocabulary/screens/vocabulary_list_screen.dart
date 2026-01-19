import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

/// Vocabulary list screen showing all saved words
class VocabularyListScreen extends ConsumerStatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  ConsumerState<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends ConsumerState<VocabularyListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'New', 'Learning', 'Mastered'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vocabularyAsync = ref.watch(vocabularyStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vocabulary',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Navigate to flashcards
                        },
                        icon: const Icon(Icons.style_rounded, size: 20),
                        label: const Text('Study'),
                      ).animate().fadeIn(delay: 100.ms),
                    ],
                  ),
                  const SizedBox(height: 4),
                  vocabularyAsync.when(
                    data: (words) => Text(
                      '${words.length} words saved',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    loading: () => const SizedBox(height: 16),
                    error: (_, __) => const SizedBox(height: 16),
                  ).animate().fadeIn(delay: 50.ms),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search words...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ).animate().fadeIn(delay: 150.ms),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    selectedColor: AppColors.accent.withOpacity(0.2),
                    checkmarkColor: AppColors.accent,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.accent : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.accent : AppColors.divider,
                      ),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 200 + index * 50));
                },
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Word list
            Expanded(
              child: vocabularyAsync.when(
                data: (words) {
                  var filtered = words;
                  if (_searchQuery.isNotEmpty) {
                    filtered = filtered.where((w) => w.word.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                  }
                  if (_selectedFilter != 'All') {
                    filtered = filtered.where((w) => _getStatus(w) == _selectedFilter).toList();
                  }

                  if (words.isEmpty) {
                    return _EmptyState(isDark: isDark);
                  }
                  if (filtered.isEmpty) {
                    return _NoResultsState(query: _searchQuery);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingS),
                    itemBuilder: (context, index) {
                      final word = filtered[index];
                      return _WordCard(
                        word: word,
                        isDark: isDark,
                        status: _getStatus(word),
                        onTap: () => _showWordDetails(context, word),
                        onDelete: () => _deleteWord(word),
                      ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatus(VocabularyWord word) {
    if (word.reviewCount == 0) return 'New';
    if (word.reviewCount >= 5 && word.correctCount / word.reviewCount > 0.8) return 'Mastered';
    return 'Learning';
  }

  void _showWordDetails(BuildContext context, VocabularyWord word) {
    // TODO: Show details
  }

  Future<void> _deleteWord(VocabularyWord word) async {
    final db = ref.read(databaseProvider);
    await db.deleteVocabularyWord(word.id);
  }
}

class _WordCard extends StatelessWidget {
  final VocabularyWord word;
  final bool isDark;
  final String status;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WordCard({
    required this.word,
    required this.isDark,
    required this.status,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Word?'),
            content: Text('Are you sure you want to remove "${word.word}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete();
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            // Word info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        word.word,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (word.partOfSpeech != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          word.partOfSpeech!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (word.definition != null)
                    Text(
                      word.definition!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Review indicator
            Column(
              children: [
                Icon(
                  Icons.replay_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 2),
                Text(
                  '${word.reviewCount}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return AppColors.accent;
      case 'Learning':
        return AppColors.warning;
      case 'Mastered':
        return AppColors.success;
      default:
        return AppColors.textTertiary;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 64,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'No words saved yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Double-tap while watching a video\nto save words to your vocabulary',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;

  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'No results for "$query"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
