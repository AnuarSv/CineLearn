import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

class MatchGameScreen extends ConsumerStatefulWidget {
  const MatchGameScreen({super.key});

  @override
  ConsumerState<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends ConsumerState<MatchGameScreen> {
  List<VocabularyWord> _words = [];
  bool _isLoading = true;
  int _score = 0;
  int _matchedCount = 0;

  List<_MatchItem> _leftItems = [];
  List<_MatchItem> _rightItems = [];
  _MatchItem? _selectedLeft;
  _MatchItem? _selectedRight;
  Set<String> _matchedIds = {};

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final database = ref.read(databaseProvider);
    final allWords = await database.getAllVocabulary();

    final validWords = allWords.where((w) => 
        w.definition != null && w.definition!.isNotEmpty
    ).toList();

    if (validWords.length < 4) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    validWords.shuffle();
    _words = validWords.take(6).toList();

    _setupGame();

    if (mounted) setState(() => _isLoading = false);
  }

  void _setupGame() {
    _leftItems = _words.map((w) => _MatchItem(
      id: w.id,
      text: w.word,
      isWord: true,
    )).toList();

    _rightItems = _words.map((w) => _MatchItem(
      id: w.id,
      text: w.definition!,
      isWord: false,
    )).toList()..shuffle();

    _matchedIds.clear();
    _matchedCount = 0;
    _selectedLeft = null;
    _selectedRight = null;
  }

  void _onLeftTap(_MatchItem item) {
    if (_matchedIds.contains(item.id)) return;

    HapticFeedback.lightImpact();

    setState(() {
      _selectedLeft = item;
    });

    _checkMatch();
  }

  void _onRightTap(_MatchItem item) {
    if (_matchedIds.contains(item.id)) return;

    HapticFeedback.lightImpact();

    setState(() {
      _selectedRight = item;
    });

    _checkMatch();
  }

  void _checkMatch() {
    if (_selectedLeft == null || _selectedRight == null) return;

    if (_selectedLeft!.id == _selectedRight!.id) {
      // Correct match
      HapticFeedback.heavyImpact();
      setState(() {
        _matchedIds.add(_selectedLeft!.id);
        _matchedCount++;
        _score++;
        _selectedLeft = null;
        _selectedRight = null;
      });

      if (_matchedCount == _words.length) {
        Future.delayed(const Duration(milliseconds: 500), _showResults);
      }
    } else {
      // Wrong match
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _selectedLeft = null;
            _selectedRight = null;
          });
        }
      });
    }
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

    if (_words.length < 4) {
      return _EmptyState(isDark: isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF5F7FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF4A148C).withOpacity(0.2), const Color(0xFF0A0E21)]
                : [const Color(0xFFF3E5F5), const Color(0xFFF5F7FA)],
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
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link, color: Colors.purple, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$_matchedCount / ${_words.length}',
                            style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
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
                    value: _matchedCount / _words.length,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    color: Colors.purple,
                    minHeight: 6,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Match words with their definitions',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Match columns
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Left column (words)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _leftItems.length,
                          itemBuilder: (context, index) {
                            final item = _leftItems[index];
                            final isMatched = _matchedIds.contains(item.id);
                            final isSelected = _selectedLeft?.id == item.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MatchCard(
                                item: item,
                                isMatched: isMatched,
                                isSelected: isSelected,
                                isWrong: _selectedLeft != null && 
                                         _selectedRight != null && 
                                         _selectedLeft!.id == item.id &&
                                         _selectedLeft!.id != _selectedRight!.id,
                                isDark: isDark,
                                onTap: () => _onLeftTap(item),
                              ),
                            ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: -0.1);
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Right column (definitions)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _rightItems.length,
                          itemBuilder: (context, index) {
                            final item = _rightItems[index];
                            final isMatched = _matchedIds.contains(item.id);
                            final isSelected = _selectedRight?.id == item.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MatchCard(
                                item: item,
                                isMatched: isMatched,
                                isSelected: isSelected,
                                isWrong: _selectedLeft != null && 
                                         _selectedRight != null && 
                                         _selectedRight!.id == item.id &&
                                         _selectedLeft!.id != _selectedRight!.id,
                                isDark: isDark,
                                onTap: () => _onRightTap(item),
                              ),
                            ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchItem {
  final String id;
  final String text;
  final bool isWord;

  _MatchItem({
    required this.id,
    required this.text,
    required this.isWord,
  });
}

class _MatchCard extends StatelessWidget {
  final _MatchItem item;
  final bool isMatched;
  final bool isSelected;
  final bool isWrong;
  final bool isDark;
  final VoidCallback onTap;

  const _MatchCard({
    required this.item,
    required this.isMatched,
    required this.isSelected,
    required this.isWrong,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isMatched) {
      backgroundColor = AppColors.success.withOpacity(0.2);
      borderColor = AppColors.success;
      textColor = AppColors.success;
    } else if (isWrong) {
      backgroundColor = AppColors.error.withOpacity(0.1);
      borderColor = AppColors.error;
      textColor = isDark ? Colors.white : Colors.black87;
    } else if (isSelected) {
      backgroundColor = Colors.purple.withOpacity(0.1);
      borderColor = Colors.purple;
      textColor = isDark ? Colors.white : Colors.black87;
    } else {
      backgroundColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
      borderColor = isDark ? Colors.white10 : Colors.grey.shade200;
      textColor = isDark ? Colors.white : Colors.black87;
    }

    return GestureDetector(
      onTap: isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMatched)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Icons.check_circle, color: AppColors.success, size: 20),
              ),
            Text(
              item.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: item.isWord ? 18 : 14,
                fontWeight: item.isWord ? FontWeight.bold : FontWeight.normal,
                color: textColor,
                height: 1.4,
                decoration: isMatched ? TextDecoration.lineThrough : null,
              ),
              maxLines: item.isWord ? 2 : 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F38) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'All Matched!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You matched all $total pairs',
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
                    backgroundColor: Colors.purple,
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
              Icon(Icons.compare_arrows, size: 64, color: Colors.purple),
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
                'Save at least 4 words with definitions to play Match Game.',
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
