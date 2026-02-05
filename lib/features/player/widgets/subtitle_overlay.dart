import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/subtitle_entry.dart';

/// Overlay showing the current subtitle with tappable words
class SubtitleOverlay extends StatelessWidget {
  final SubtitleEntry subtitle;
  final Function(String word) onWordTap;
  final VoidCallback onDismiss;

  const SubtitleOverlay({
    super.key,
    required this.subtitle,
    required this.onWordTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dismiss hint
            Text(
              'Tap anywhere to continue',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ).animate().fadeIn(delay: 500.ms),
            
            const SizedBox(height: 24),
            
            // Subtitle container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Instructions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap any word for definition',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Words
                  Builder(
                    builder: (context) {
                      final isJapanese = RegExp(r'[\u3040-\u30ff\u4e00-\u9faf]').hasMatch(subtitle.text);
                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: isJapanese ? 2 : 6,
                        runSpacing: isJapanese ? 4 : 8,
                        children: subtitle.words.asMap().entries.map((entry) {
                          return _TappableWord(
                            word: entry.value,
                            index: entry.key,
                            isJapanese: isJapanese,
                            onTap: () => onWordTap(entry.value),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            
            const SizedBox(height: 24),
            
            // Full subtitle text
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                subtitle.text,
                style: AppTypography.subtitle,
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }
}

class _TappableWord extends StatefulWidget {
  final String word;
  final int index;
  final bool isJapanese;
  final VoidCallback onTap;

  const _TappableWord({
    required this.word,
    required this.index,
    this.isJapanese = false,
    required this.onTap,
  });

  @override
  State<_TappableWord> createState() => _TappableWordState();
}

class _TappableWordState extends State<_TappableWord> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isJapanese ? 4 : 12, 
          vertical: widget.isJapanese ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.accent
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(widget.isJapanese ? 4 : 8),
          border: Border.all(
            color: _isPressed
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          widget.word,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.isJapanese ? 22 : 18, // Japanese characters are often complex, better to show larger
            fontWeight: FontWeight.w500,
          ),
        ),
      ).animate(delay: Duration(milliseconds: (widget.isJapanese ? 10 : 50) * widget.index))
          .fadeIn()
          .slideY(begin: 0.2),
    );
  }
}
