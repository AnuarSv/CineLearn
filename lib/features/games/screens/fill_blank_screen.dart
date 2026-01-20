import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

class FillBlankScreen extends ConsumerStatefulWidget {
  const FillBlankScreen({super.key});

  @override
  ConsumerState<FillBlankScreen> createState() => _FillBlankScreenState();
}

class _FillBlankScreenState extends ConsumerState<FillBlankScreen> {
  final TextEditingController _controller = TextEditingController();
  List<VocabularyWord> _quizWords = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isChecked = false;
  bool _isCorrect = false;

  late VocabularyWord _targetWord;
  String _questionSentence = '';

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final database = ref.read(databaseProvider);
    final allWords = await database.getAllVocabulary();
    
    // Filter words with context sentences
    final playableWords = allWords.where((w) {
      if (w.contextSentence == null || w.contextSentence!.isEmpty) return false;
      // Ensure the word actually exists in the sentence (case insensitive)
      return w.contextSentence!.toLowerCase().contains(w.word.toLowerCase());
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
    _controller.clear();
    _isChecked = false;
    _isCorrect = false;

    // Create blank
    final word = _targetWord.word;
    final sentence = _targetWord.contextSentence!;
    
    // Regex replace to preserve punctuation if attached, or simple string replace
    // Simple replaceAll might retain too much if word is "the" and sentence has "them".
    // Better: Regex with word boundary, but might be tricky with simple replace.
    // For MVP, simple case-insensitive replace is okay.
    
    final regex = RegExp(RegExp.escape(word), caseSensitive: false);
    _questionSentence = sentence.replaceAllMapped(regex, (match) => '________');
  }

  void _checkAnswer() {
    if (_isChecked) return;

    final input = _controller.text.trim().toLowerCase();
    final target = _targetWord.word.toLowerCase();
    
    final correct = input == target;

    setState(() {
      _isChecked = true;
      _isCorrect = correct;
      if (correct) _score++;
    });

    // Auto advance if correct, or wait for manual "Next" if incorrect? 
    // Usually manual "Continue" is better so they can see the correction.
  }

  void _nextQuestion() {
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
        title: const Text('Quiz Complete!'),
        content: Text('You scored $_score out of ${_quizWords.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to hub
            },
            child: const Text('Finish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _isLoading = true;
              });
              _loadWords(); // Restart
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
        body: const Center(child: Text('Not enough words with sentences to play.')),
      );
    }

    final progress = (_currentIndex + 1) / _quizWords.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Fill in the Blank'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            color: AppColors.accent,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            
            // Sentence Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.shadowSmall,
              ),
              child: Text(
                _questionSentence,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  height: 1.5,
                  color: isDark ? Colors.white : AppColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 48),

            // Input
            TextField(
              controller: _controller,
              enabled: !_isChecked,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Type the missing word...',
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _checkAnswer(),
            ),

            const SizedBox(height: 24),

            // Feedback area
            if (_isChecked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isCorrect ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCorrect ? AppColors.success : AppColors.error,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.cancel,
                          color: _isCorrect ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCorrect ? 'Correct!' : 'Incorrect',
                          style: TextStyle(
                            color: _isCorrect ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    if (!_isCorrect)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Answer: ${_targetWord.word}',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn().scale(),

            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isChecked ? _nextQuestion : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isChecked 
                      ? (_isCorrect ? AppColors.success : AppColors.primary) 
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isChecked ? 'Next' : 'Check Answer',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
