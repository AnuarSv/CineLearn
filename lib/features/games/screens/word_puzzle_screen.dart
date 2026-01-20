import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

class WordPuzzleScreen extends ConsumerStatefulWidget {
  const WordPuzzleScreen({super.key});

  @override
  ConsumerState<WordPuzzleScreen> createState() => _WordPuzzleScreenState();
}

class _WordPuzzleScreenState extends ConsumerState<WordPuzzleScreen> {
  List<VocabularyWord> _quizWords = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isSuccess = false;
  bool _isError = false;

  late VocabularyWord _targetWord;
  List<String> _targetChars = [];
  List<String?> _slots = []; // Null means empty
  List<String?> _pool = []; // Null means used in slot

  // Mapping to track which pool index moved to which slot index could be complex.
  // Simpler approach: 
  // - _poolItems: List of {char, id, isUsed}
  // - _slotItems: List of {char, id} (or null)

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final database = ref.read(databaseProvider);
    final allWords = await database.getAllVocabulary();
    
    // Filter words with definitions and reasonable length
    final playableWords = allWords.where((w) {
      final clean = w.word.trim();
      return clean.length >= 3 && clean.length <= 10 && w.definition != null;
    }).toList();

    if (playableWords.length < 3) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    playableWords.shuffle();
    _quizWords = playableWords.take(10).toList();
    
    _setupQuestion();
    
    if (mounted) setState(() => _isLoading = false);
  }

  void _setupQuestion() {
    if (_currentIndex >= _quizWords.length) return;

    _targetWord = _quizWords[_currentIndex];
    final cleanWord = _targetWord.word.trim().toUpperCase();
    _targetChars = cleanWord.split('');
    _slots = List.filled(_targetChars.length, null);
    
    // Create pool
    _pool = List.from(_targetChars);
    _pool.shuffle();
    
    _isSuccess = false;
    _isError = false;
  }

  void _onPoolTap(int index) {
    if (_isSuccess || _pool[index] == null) return;
    
    // Find first empty slot
    final emptySlotIndex = _slots.indexOf(null);
    if (emptySlotIndex != -1) {
      setState(() {
        _slots[emptySlotIndex] = _pool[index];
        _pool[index] = null; // Mark as used
        _isError = false;
      });
      _checkCompletion();
    }
  }

  void _onSlotTap(int index) {
    if (_isSuccess || _slots[index] == null) return;

    // Return to pool (we need to find the original slot or just any null slot in pool?
    // Actually, since pool is position-based, we need to know WHICH pool item this was.
    // Simpler: Just put it back into the first null spot in pool matching the char? 
    // Or just put it back into ANY null spot in pool?
    // User expects it to go back to where it came from usually, but just filling any gap is okay for MVP.
    // Better: Reconstruct the pool list logic effectively.
    
    final charToReturn = _slots[index];
    final emptyPoolIndex = _pool.indexOf(null);
    
    if (emptyPoolIndex != -1) {
      setState(() {
        _pool[emptyPoolIndex] = charToReturn;
        _slots[index] = null;
        _isError = false;
      });
    }
  }

  void _checkCompletion() {
    if (!_slots.contains(null)) {
      final formedWord = _slots.join('');
      if (formedWord == _targetWord.word.trim().toUpperCase()) {
        setState(() {
          _isSuccess = true;
          _score++;
        });
        Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
      } else {
         setState(() => _isError = true);
         // Shake effect or red highlight handled in build
      }
    }
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex < _quizWords.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _setupQuestion();
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Puzzle Complete!'),
        content: Text('You solved $_score out of ${_quizWords.length} words'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Finish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _isLoading = true;
              });
              _loadWords();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_quizWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Not enough words to play.')),
      );
    }

    final progress = (_currentIndex + 1) / _quizWords.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Word Puzzle'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            color: _isSuccess ? AppColors.success : AppColors.accent,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(flex: 1),
            // Definition / Clue
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.shadowSmall,
              ),
              child: Column(
                children: [
                  const Text(
                    'DEFINITION',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _targetWord.definition ?? 'No definition',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2),
            
            const Spacer(flex: 2),

            // Slots
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_slots.length, (index) {
                final char = _slots[index];
                return GestureDetector(
                  onTap: () => _onSlotTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: char != null 
                          ? (_isSuccess ? AppColors.success : (_isError ? AppColors.error : AppColors.primary))
                          : (isDark ? Colors.white10 : Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                         color: char != null ? Colors.transparent : AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        char ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const Spacer(flex: 1),

            // Pool
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_pool.length, (index) {
                final char = _pool[index];
                return GestureDetector(
                  onTap: () => _onPoolTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: char != null 
                          ? (isDark ? AppColors.darkSurface : Colors.white)
                          : Colors.transparent, // Hidden if used
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: char != null ? AppTheme.shadowSmall : null,
                      border: char != null ? null : Border.all(color: Colors.transparent),
                    ),
                    child: char != null ? Center(
                      child: Text(
                        char,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textMain,
                        ),
                      ),
                    ) : null,
                  ),
                );
              }),
            ),
            
            const Spacer(flex: 2),
            
            if (_isSuccess)
              const Text(
                'CORRECT!',
                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 24),
              ).animate().fadeIn().scale(),
          ],
        ),
      ),
    );
  }
}
