import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

class WordPuzzleScreen extends ConsumerStatefulWidget {
  const WordPuzzleScreen({super.key});

  @override
  ConsumerState<WordPuzzleScreen> createState() => _WordPuzzleScreenState();
}

class _WordPuzzleScreenState extends ConsumerState<WordPuzzleScreen> with TickerProviderStateMixin {
  List<VocabularyWord> _words = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasWon = false;
  bool _hasLost = false;

  late VocabularyWord _targetWord;
  List<String> _shuffledLetters = [];
  List<String?> _slots = [];
  int _attempts = 0;
  static const int _maxAttempts = 3;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final database = ref.read(databaseProvider);
    final allWords = await database.getAllVocabulary();

    if (allWords.length < 2) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    allWords.shuffle();
    _words = allWords.take(10).toList();
    _setupPuzzle();

    if (mounted) setState(() => _isLoading = false);
  }

  void _setupPuzzle() {
    if (_currentIndex >= _words.length) return;

    _targetWord = _words[_currentIndex];
    _shuffledLetters = _targetWord.word.toUpperCase().split('')..shuffle();
    _slots = List.filled(_targetWord.word.length, null);
    _hasWon = false;
    _hasLost = false;
    _attempts = 0;
  }

  void _onLetterTap(int letterIndex) {
    if (_hasWon || _hasLost) return;

    // Find first empty slot
    final slotIndex = _slots.indexOf(null);
    if (slotIndex == -1) return;

    HapticFeedback.lightImpact();

    setState(() {
      _slots[slotIndex] = _shuffledLetters[letterIndex];
      _shuffledLetters[letterIndex] = '';
    });

    // Check if complete
    if (!_slots.contains(null)) {
      _checkAnswer();
    }
  }

  void _onSlotTap(int slotIndex) {
    if (_hasWon || _hasLost) return;
    if (_slots[slotIndex] == null) return;

    HapticFeedback.lightImpact();

    // Return letter to pool
    final letter = _slots[slotIndex]!;
    final emptyIndex = _shuffledLetters.indexOf('');
    
    setState(() {
      _slots[slotIndex] = null;
      if (emptyIndex != -1) {
        _shuffledLetters[emptyIndex] = letter;
      }
    });
  }

  void _checkAnswer() {
    final answer = _slots.join('');
    final correct = _targetWord.word.toUpperCase();

    if (answer == correct) {
      HapticFeedback.heavyImpact();
      setState(() {
        _hasWon = true;
        _score++;
      });
      _nextWord(delay: const Duration(milliseconds: 1500));
    } else {
      _attempts++;
      if (_attempts >= _maxAttempts) {
        setState(() => _hasLost = true);
        _nextWord(delay: const Duration(milliseconds: 2000));
      } else {
        // Shake and reset
        HapticFeedback.mediumImpact();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _shuffledLetters = _targetWord.word.toUpperCase().split('')..shuffle();
              _slots = List.filled(_targetWord.word.length, null);
            });
          }
        });
      }
    }
  }

  void _nextWord({Duration delay = Duration.zero}) {
    Future.delayed(delay, () {
      if (!mounted) return;
      if (_currentIndex < _words.length - 1) {
        setState(() => _currentIndex++);
        _setupPuzzle();
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => _ResultsSheet(
        score: _score,
        total: _words.length,
        onFinish: () {
          Navigator.pop(context);
          context.pop();
        },
        onRetry: () {
          Navigator.pop(context);
          setState(() {
            _currentIndex = 0;
            _score = 0;
            _isLoading = true;
          });
          _loadWords();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0E21) : Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_words.isEmpty) {
      return _EmptyState(isDark: isDark);
    }

    final progress = (_currentIndex + 1) / _words.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF5F7FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A237E).withOpacity(0.3), const Color(0xFF0A0E21)]
                : [const Color(0xFFE3F2FD), const Color(0xFFF5F7FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.primary, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$_score',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Definition hint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.accent,
                        size: 28,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _targetWord.definition ?? 'Unscramble the word',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: -0.1),

              const Spacer(),

              // Answer slots
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_slots.length, (index) {
                    final letter = _slots[index];
                    final isCorrect = _hasWon;
                    final isWrong = _hasLost;

                    return GestureDetector(
                      onTap: () => _onSlotTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppColors.success
                              : isWrong
                                  ? AppColors.error
                                  : (letter != null
                                      ? (isDark ? AppColors.primary : AppColors.primary.withOpacity(0.9))
                                      : (isDark ? Colors.white10 : Colors.white)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: letter == null
                                ? (isDark ? Colors.white24 : Colors.grey.shade300)
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: letter != null
                              ? [
                                  BoxShadow(
                                    color: (isCorrect ? AppColors.success : AppColors.primary)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            letter ?? '',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: letter != null ? Colors.white : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ).animate(delay: (index * 50).ms).scale(begin: const Offset(0.8, 0.8));
                  }),
                ),
              ),

              if (_hasLost) ...[
                const SizedBox(height: 16),
                Text(
                  'Correct: ${_targetWord.word.toUpperCase()}',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(),
              ],

              const Spacer(),

              // Letter pool
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_shuffledLetters.length, (index) {
                    final letter = _shuffledLetters[index];
                    if (letter.isEmpty) {
                      return const SizedBox(width: 52, height: 56);
                    }

                    return GestureDetector(
                      onTap: () => _onLetterTap(index),
                      child: Container(
                        width: 52,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [const Color(0xFF2A2F4A), const Color(0xFF1A1F38)]
                                : [Colors.white, Colors.grey.shade100],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ).animate(delay: (index * 30).ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // Attempts indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_maxAttempts, (index) {
                  final isUsed = index < _attempts;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isUsed ? Icons.favorite : Icons.favorite_border,
                      color: isUsed ? Colors.grey : AppColors.error,
                      size: 24,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsSheet extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onFinish;
  final VoidCallback onRetry;

  const _ResultsSheet({
    required this.score,
    required this.total,
    required this.onFinish,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (score / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F38) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            percentage >= 70 ? '🧩' : '🔤',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            percentage >= 70 ? 'Puzzle Master!' : 'Keep Practicing!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score / $total correct',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onFinish,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Play Again', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.extension_outlined, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'No Words Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Save some words to play Word Puzzle.',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
