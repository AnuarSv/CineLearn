import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/dictionary_cache_service.dart';
import '../../../data/models/vocabulary_word.dart';
import 'package:uuid/uuid.dart';

/// Bottom sheet popup showing word definition with local caching
class WordPopup extends StatefulWidget {
  final String word;
  final String contextSentence;
  final Duration timestamp;
  final String videoId;
  final DictionaryCacheService cacheService;
  final VoidCallback onClose;
  final Function(VocabularyWord) onSave;

  const WordPopup({
    super.key,
    required this.word,
    required this.contextSentence,
    required this.timestamp,
    required this.videoId,
    required this.cacheService,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<WordPopup> createState() => _WordPopupState();
}

class _WordPopupState extends State<WordPopup> {
  CachedWordDefinition? _definition;
  bool _isLoading = true;
  String? _error;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadDefinition();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadDefinition() async {
    try {
      final definition = await widget.cacheService.lookupWord(widget.word);
      if (mounted) {
        setState(() {
          _definition = definition;
          _isLoading = false;
          if (definition == null) {
            _error = 'No definition found';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load definition';
        });
      }
    }
  }

  Future<void> _playAudio() async {
    if (_definition?.audioUrl != null) {
      try {
        await _audioPlayer.play(UrlSource(_definition!.audioUrl!));
      } catch (e) {
        // Ignore audio errors
      }
    }
  }

  void _saveWord() {
    if (_definition == null) return;

    final vocabularyWord = VocabularyWord(
      id: const Uuid().v4(),
      word: _definition!.word,
      partOfSpeech: _definition!.partOfSpeech,
      definition: _definition!.definition,
      example: _definition!.example,
      phonetic: _definition!.phonetic,
      audioUrl: _definition!.audioUrl,
      videoId: widget.videoId,
      timestamp: widget.timestamp,
      contextSentence: widget.contextSentence,
      savedAt: DateTime.now(),
    );

    widget.onSave(vocabularyWord);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isLoading
                ? const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _error != null
                    ? _buildErrorState()
                    : _buildDefinitionContent(isDark),
          ).animate().fadeIn(duration: 200.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.search_off, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        Text(
          _error ?? 'No definition found',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDefinitionContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Word and pronunciation
        Row(
          children: [
            Expanded(
              child: Text(
                _definition!.word,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textMain,
                ),
              ),
            ),
            if (_definition!.audioUrl != null)
              IconButton(
                onPressed: _playAudio,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volume_up, color: AppColors.accent),
                ),
              ),
          ],
        ),
        
        if (_definition!.phonetic != null) ...[
          const SizedBox(height: 4),
          Text(
            _definition!.phonetic!,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        
        if (_definition!.partOfSpeech != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _definition!.partOfSpeech!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Definition
        Text(
          _definition!.definition,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: isDark ? Colors.white : AppColors.textMain,
          ),
        ),
        
        if (_definition!.example != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: AppColors.accent, width: 3),
              ),
            ),
            child: Text(
              '"${_definition!.example!}"',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onClose,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _saveWord,
                icon: const Icon(Icons.bookmark_add, size: 20),
                label: const Text('Save Word'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
