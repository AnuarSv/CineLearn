import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/oxford_dictionary_service.dart';
import '../../../data/models/vocabulary_word.dart';
import 'package:uuid/uuid.dart';

/// Bottom sheet popup showing word definition from Oxford Dictionary
class WordPopup extends StatefulWidget {
  final String word;
  final String contextSentence;
  final Duration timestamp;
  final String videoId;
  final OxfordDictionaryService dictionaryService;
  final VoidCallback onClose;
  final Function(VocabularyWord) onSave;

  const WordPopup({
    super.key,
    required this.word,
    required this.contextSentence,
    required this.timestamp,
    required this.videoId,
    required this.dictionaryService,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<WordPopup> createState() => _WordPopupState();
}

class _WordPopupState extends State<WordPopup> {
  WordDefinition? _definition;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDefinition();
  }

  Future<void> _loadDefinition() async {
    try {
      final definition = await widget.dictionaryService.lookupWord(widget.word);
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Word header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.word,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ).animate().fadeIn(),
                          if (_definition?.phonetic != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _definition!.pronunciationDisplay,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ).animate().fadeIn(delay: 100.ms),
                          ],
                          if (_definition?.partOfSpeech != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _definition!.partOfSpeech!,
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: AppColors.textTertiary),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Definition
                if (_isLoading)
                  _LoadingState()
                else if (_error != null)
                  _ErrorState(error: _error!)
                else if (_definition != null)
                  _DefinitionContent(definition: _definition!),

                const SizedBox(height: 16),

                // Context sentence
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.contextSentence,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _definition != null ? _saveWord : null,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: const Text('Save to Vocabulary'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
              ],
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Looking up definition...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefinitionContent extends StatelessWidget {
  final WordDefinition definition;

  const _DefinitionContent({required this.definition});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Definition
        Text(
          'Definition',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          definition.definition,
          style: Theme.of(context).textTheme.bodyLarge,
        ).animate().fadeIn(delay: 300.ms),

        // Example (if available)
        if (definition.example != null) ...[
          const SizedBox(height: 16),
          Text(
            'Example',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${definition.example}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 350.ms),
        ],

        // Synonyms (if available)
        if (definition.synonyms.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Synonyms',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: definition.synonyms.take(5).map((syn) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  syn,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ],
    );
  }
}
