import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

class ListeningQuizScreen extends ConsumerStatefulWidget {
  const ListeningQuizScreen({super.key});

  @override
  ConsumerState<ListeningQuizScreen> createState() => _ListeningQuizScreenState();
}

class _ListeningQuizScreenState extends ConsumerState<ListeningQuizScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<VocabularyWord> _quizWords = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasAnswered = false;
  String? _selectedWord;
  
  // Current question data
  late VocabularyWord _targetWord;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    final database = ref.read(databaseProvider);
    final allWords = await database.getAllVocabulary();
    
    // Filter words that have audio
    final playableWords = allWords.where((w) => w.audioUrl != null && w.audioUrl!.isNotEmpty).toList();
    
    if (playableWords.length < 4) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    playableWords.shuffle();
    _quizWords = playableWords.take(10).toList(); // Take up to 10 words for the session

    _setupQuestion();
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _setupQuestion() {
    if (_currentIndex >= _quizWords.length) return;

    _targetWord = _quizWords[_currentIndex];
    _hasAnswered = false;
    _selectedWord = null;

    // Generate options
    final database = ref.read(databaseProvider);
    // We already have the list, let's just pick from our loaded pool or use the full list if available?
    // For simplicity, let's just use the _quizWords list for distractors if possible, 
    // or we'd ideally need the full pool to avoid repetition. 
    // Since we filtered playableWords, let's assume we can pick from there.
    // For now, let's just pick from _quizWords and generic logic.
    
    final distractors = List<VocabularyWord>.from(_quizWords)..remove(_targetWord);
    distractors.shuffle();
    
    _options = distractors.take(3).map((w) => w.word).toList();
    _options.add(_targetWord.word);
    _options.shuffle();

    _playAudio();
  }

  Future<void> _playAudio() async {
    if (_targetWord.audioUrl == null) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(_targetWord.audioUrl!));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  void _onOptionSelected(String word) {
    if (_hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _selectedWord = word;
      if (word == _targetWord.word) {
        _score++;
        // Optional: Play success sound
      } else {
        // Optional: Play error sound
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentIndex < _quizWords.length - 1) {
        setState(() => _currentIndex++);
        _setupQuestion();
      } else {
        _showResults();
      }
    });
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

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Not enough words with audio to play. Save more distinct words!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      );
    }

    final progress = (_currentIndex + 1) / _quizWords.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Listening Quiz'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            color: AppColors.accent,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Audio Button
            GestureDetector(
              onTap: _playAudio,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  size: 64,
                  color: AppColors.accent,
                ),
              ),
            ).animate(target: _hasAnswered ? 0 : 1).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds),
            
            const SizedBox(height: 16),
            const Text('Tap to listen again', style: TextStyle(color: AppColors.textSecondary)),
            
            const Spacer(),

            // Options
            ..._options.map((option) {
              final isSelected = option == _selectedWord;
              final isCorrect = option == _targetWord.word;
              
              Color? btnColor;
              if (_hasAnswered) {
                if (isCorrect) {
                  btnColor = AppColors.success;
                } else if (isSelected) {
                  btnColor = AppColors.error;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: btnColor ?? (isDark ? AppColors.darkSurface : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: btnColor ?? Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      if (btnColor == null)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onOptionSelected(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Text(
                          option.toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _hasAnswered && (isCorrect || isSelected)
                                ? Colors.white
                                : (isDark ? Colors.white : AppColors.textMain),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
