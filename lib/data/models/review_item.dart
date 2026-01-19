/// Review item for TikTok-style Reels feed
class ReviewItem {
  final String id;
  final String vocabularyId;
  final String word;
  final String definition;
  final String contextSentence;
  
  // Video clip data
  final String videoId;
  final String videoPath;
  final Duration clipStart;
  final Duration clipEnd;
  final String? clipPath; // Pre-generated clip file path
  
  // Quiz data
  final ReviewType reviewType;
  final List<String>? options; // For multiple choice
  final String correctAnswer;
  
  // Progress
  final bool isCompleted;
  final bool? wasCorrect;
  final DateTime? completedAt;

  ReviewItem({
    required this.id,
    required this.vocabularyId,
    required this.word,
    required this.definition,
    required this.contextSentence,
    required this.videoId,
    required this.videoPath,
    required this.clipStart,
    required this.clipEnd,
    this.clipPath,
    required this.reviewType,
    this.options,
    required this.correctAnswer,
    this.isCompleted = false,
    this.wasCorrect,
    this.completedAt,
  });

  /// Duration of the clip
  Duration get clipDuration => clipEnd - clipStart;

  /// Copy with modifications
  ReviewItem copyWith({
    String? id,
    String? vocabularyId,
    String? word,
    String? definition,
    String? contextSentence,
    String? videoId,
    String? videoPath,
    Duration? clipStart,
    Duration? clipEnd,
    String? clipPath,
    ReviewType? reviewType,
    List<String>? options,
    String? correctAnswer,
    bool? isCompleted,
    bool? wasCorrect,
    DateTime? completedAt,
  }) {
    return ReviewItem(
      id: id ?? this.id,
      vocabularyId: vocabularyId ?? this.vocabularyId,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      contextSentence: contextSentence ?? this.contextSentence,
      videoId: videoId ?? this.videoId,
      videoPath: videoPath ?? this.videoPath,
      clipStart: clipStart ?? this.clipStart,
      clipEnd: clipEnd ?? this.clipEnd,
      clipPath: clipPath ?? this.clipPath,
      reviewType: reviewType ?? this.reviewType,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      isCompleted: isCompleted ?? this.isCompleted,
      wasCorrect: wasCorrect ?? this.wasCorrect,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'ReviewItem(word: $word, type: $reviewType, completed: $isCompleted)';
  }
}

/// Types of review exercises
enum ReviewType {
  /// Type what you heard
  typing,
  
  /// Rearrange letters/words to form the answer
  puzzle,
  
  /// Fill in the missing word
  fillBlank,
  
  /// Choose the correct definition
  multipleChoice,
  
  /// Listen and select what was said
  listeningChoice,
}

extension ReviewTypeExtension on ReviewType {
  String get displayName {
    switch (this) {
      case ReviewType.typing:
        return 'Type what you hear';
      case ReviewType.puzzle:
        return 'Word Puzzle';
      case ReviewType.fillBlank:
        return 'Fill in the Blank';
      case ReviewType.multipleChoice:
        return 'Multiple Choice';
      case ReviewType.listeningChoice:
        return 'Listening Quiz';
    }
  }

  String get icon {
    switch (this) {
      case ReviewType.typing:
        return '⌨️';
      case ReviewType.puzzle:
        return '🧩';
      case ReviewType.fillBlank:
        return '📝';
      case ReviewType.multipleChoice:
        return '✅';
      case ReviewType.listeningChoice:
        return '👂';
    }
  }
}
