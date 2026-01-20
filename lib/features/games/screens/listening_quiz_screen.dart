import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../../app/theme/colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

class ListeningQuizScreen extends ConsumerStatefulWidget {
  const ListeningQuizScreen({super.key});

  @override
  ConsumerState<ListeningQuizScreen> createState() => _ListeningQuizScreenState();
}

class _ListeningQuizScreenState extends ConsumerState<ListeningQuizScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  List<VocabularyWord> _quizWords = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasAnswered = false;
  String? _selectedWord;

  late VocabularyWord _targetWord;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadWords();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    final database = ref.read(databaseProvider);
    final allWords = await database.getAllVocabulary();

    final playableWords = allWords.where((w) => w.audioUrl != null && w.audioUrl!.isNotEmpty).toList();

    if (playableWords.length < 4) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    playableWords.shuffle();
    _quizWords = playableWords.take(10).toList();

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

    HapticFeedback.mediumImpact();

    setState(() {
      _hasAnswered = true;
      _selectedWord = word;
      if (word == _targetWord.word) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
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
    _confettiController.play();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => _ResultsSheet(
        score: _score,
        total: _quizWords.length,
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headphones, size: 40, color: AppColors.accent),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.5.seconds),
              const SizedBox(height: 24),
              Text('Loading quiz...', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_quizWords.isEmpty) {
      return _EmptyState(isDark: isDark);
    }

    final progress = (_currentIndex + 1) / _quizWords.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0A0E21), const Color(0xFF1A1F38)]
                    : [const Color(0xFFF5F7FA), const Color(0xFFE8ECF4)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // App bar
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
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${_quizWords.length}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? Colors.white10 : Colors.black12,
                      color: AppColors.accent,
                      minHeight: 6,
                    ),
                  ),
                ),

                const Spacer(),

                // Audio button
                GestureDetector(
                  onTap: _playAudio,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accent,
                          AppColors.accent.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ).animate(target: _hasAnswered ? 0 : 1)
                    .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 600.ms)
                    .then()
                    .scale(begin: const Offset(1.05, 1.05), end: const Offset(1, 1), duration: 600.ms),

                const SizedBox(height: 16),
                
                Text(
                  'Tap to listen',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const Spacer(),

                // Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: _options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      return _OptionButton(
                        option: option,
                        index: index,
                        isSelected: option == _selectedWord,
                        isCorrect: option == _targetWord.word,
                        hasAnswered: _hasAnswered,
                        isDark: isDark,
                        onTap: () => _onOptionSelected(option),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                AppColors.primary,
                AppColors.accent,
                AppColors.success,
                Colors.orange,
                Colors.pink,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (hasAnswered) {
      if (isCorrect) {
        backgroundColor = AppColors.success;
        borderColor = AppColors.success;
        textColor = Colors.white;
      } else if (isSelected) {
        backgroundColor = AppColors.error;
        borderColor = AppColors.error;
        textColor = Colors.white;
      } else {
        backgroundColor = isDark ? const Color(0xFF1A1F38) : Colors.white;
        borderColor = isDark ? Colors.white10 : Colors.grey.shade300;
        textColor = isDark ? Colors.white54 : Colors.grey;
      }
    } else {
      backgroundColor = isDark ? const Color(0xFF1A1F38) : Colors.white;
      borderColor = isDark ? Colors.white10 : Colors.grey.shade200;
      textColor = isDark ? Colors.white : Colors.black87;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasAnswered && isCorrect)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  ),
                if (hasAnswered && isSelected && !isCorrect)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: const Icon(Icons.cancel, color: Colors.white, size: 20),
                  ),
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (100 * index).ms).fadeIn().slideY(begin: 0.1);
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
    final percentage = (score / total * 100).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String emoji;
    String message;
    if (percentage >= 80) {
      emoji = '🎉';
      message = 'Excellent!';
    } else if (percentage >= 60) {
      emoji = '👍';
      message = 'Good job!';
    } else {
      emoji = '💪';
      message = 'Keep practicing!';
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F38) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64))
              .animate().scale(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You scored $score out of $total',
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
                    side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Finish',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headphones_outlined, size: 50, color: AppColors.accent),
              ),
              const SizedBox(height: 24),
              Text(
                'Not Enough Words',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Save at least 4 words with audio to play the Listening Quiz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
