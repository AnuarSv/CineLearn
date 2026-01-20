import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

class MatchGameScreen extends ConsumerStatefulWidget {
  const MatchGameScreen({super.key});

  @override
  ConsumerState<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends ConsumerState<MatchGameScreen> {
  List<VocabularyWord> _gameItems = [];
  
  // Display lists
  List<VocabularyWord> _leftItems = [];
  List<VocabularyWord> _rightItems = [];
  
  // State
  Set<String> _matchedIds = {};
  String? _selectedLeftId;
  String? _selectedRightId;
  
  bool _isLoading = true;
  bool _isError = false; // Incorrect match attempt

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final database = ref.read(databaseProvider);
    final allWords = await database.getAllVocabulary();
    
    // Filter words with definitions
    final playableWords = allWords.where((w) => w.definition != null && w.definition!.isNotEmpty).toList();

    if (playableWords.length < 4) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    playableWords.shuffle();
    _gameItems = playableWords.take(5).toList(); // 5 pairs
    
    // Setup columns
    _leftItems = List.from(_gameItems); // Words
    _rightItems = List.from(_gameItems)..shuffle(); // Definitions
    
    if (mounted) setState(() => _isLoading = false);
  }

  void _onLeftTap(VocabularyWord item) {
    if (_matchedIds.contains(item.id)) return;
    
    setState(() {
      _selectedLeftId = item.id;
      _isError = false;
    });
    
    _checkMatch();
  }

  void _onRightTap(VocabularyWord item) {
    if (_matchedIds.contains(item.id)) return;

    setState(() {
      _selectedRightId = item.id;
      _isError = false;
    });
    
    _checkMatch();
  }

  void _checkMatch() {
    if (_selectedLeftId != null && _selectedRightId != null) {
      if (_selectedLeftId == _selectedRightId) {
        // Match!
        setState(() {
          _matchedIds.add(_selectedLeftId!);
          _selectedLeftId = null;
          _selectedRightId = null;
        });
        
        // Success sound?
        
        if (_matchedIds.length == _gameItems.length) {
          Future.delayed(const Duration(seconds: 1), _showResults);
        }
      } else {
        // No match
        setState(() => _isError = true);
        
        // Clear selection after delay
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _selectedLeftId = null;
              _selectedRightId = null;
              _isError = false;
            });
          }
        });
      }
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Great Job!'),
        content: const Text('You matched all pairs!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close
              context.pop(); // Back to hub
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _matchedIds.clear();
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
    if (_gameItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Not enough words to play match game.')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(title: const Text('Match Game')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left Column (Words)
            Expanded(
              child: ListView.separated(
                itemCount: _leftItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _leftItems[index];
                  final isSelected = _selectedLeftId == item.id;
                  final isMatched = _matchedIds.contains(item.id);
                  
                  return _CardItem(
                    text: item.word,
                    isSelected: isSelected,
                    isMatched: isMatched,
                    isError: isSelected && _isError, // Show error only if this is selected
                    onTap: () => _onLeftTap(item),
                    isDark: isDark,
                  );
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Right Column (Definitions)
            Expanded(
              child: ListView.separated(
                itemCount: _rightItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _rightItems[index];
                  final isSelected = _selectedRightId == item.id;
                  final isMatched = _matchedIds.contains(item.id);

                  return _CardItem(
                    text: item.definition ?? '',
                    isSelected: isSelected,
                    isMatched: isMatched,
                    isError: isSelected && _isError,
                    onTap: () => _onRightTap(item),
                    isSmall: true,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isMatched;
  final bool isError;
  final bool isSmall;
  final bool isDark;
  final VoidCallback onTap;

  const _CardItem({
    required this.text,
    required this.isSelected,
    required this.isMatched,
    required this.isError,
    required this.onTap,
    required this.isDark,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = isDark ? AppColors.darkSurface : Colors.white;
    Color borderColor = Colors.transparent;
    
    if (isMatched) {
      bgColor = Colors.transparent; // Hide or fade
    } else if (isError) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      borderColor = AppColors.error;
    } else if (isSelected) {
      bgColor = AppColors.primary.withValues(alpha: 0.1);
      borderColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isMatched ? 0.0 : 1.0, // Fade out on match
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 80),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isMatched ? [] : AppTheme.shadowSmall,
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmall ? 13 : 16,
                fontWeight: isSmall ? FontWeight.normal : FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textMain,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
