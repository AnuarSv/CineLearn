/// Vocabulary word model with Oxford Dictionary data
class VocabularyWord {
  final String id;
  final String word;
  final String? partOfSpeech; // noun, verb, adjective, etc.
  final String? definition; // English definition
  final String? example; // Example sentence
  final String? phonetic; // IPA pronunciation
  final String? audioUrl; // Pronunciation audio URL
  
  // Context from video
  final String videoId;
  final String? videoTitle;
  final Duration timestamp; // Position in video where word was saved
  final String contextSentence; // The subtitle text containing the word
  
  // Learning data
  final DateTime savedAt;
  final DateTime? lastReviewedAt;
  final int reviewCount;
  final int correctCount;
  final double easeFactor; // SM-2 ease factor
  final int interval; // Days until next review
  final DateTime? nextReviewAt;

  VocabularyWord({
    required this.id,
    required this.word,
    this.partOfSpeech,
    this.definition,
    this.example,
    this.phonetic,
    this.audioUrl,
    required this.videoId,
    this.videoTitle,
    required this.timestamp,
    required this.contextSentence,
    required this.savedAt,
    this.lastReviewedAt,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.easeFactor = 2.5,
    this.interval = 1,
    this.nextReviewAt,
  });

  /// Check if word is due for review
  bool get isDueForReview {
    if (nextReviewAt == null) return true;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  /// Success rate as percentage
  double get successRate {
    if (reviewCount == 0) return 0.0;
    return correctCount / reviewCount;
  }

  /// Mastery level based on success rate and review count
  String get masteryLevel {
    if (reviewCount < 3) return 'New';
    if (successRate >= 0.9 && reviewCount >= 10) return 'Mastered';
    if (successRate >= 0.7) return 'Learning';
    return 'Struggling';
  }

  /// Copy with modifications
  VocabularyWord copyWith({
    String? id,
    String? word,
    String? partOfSpeech,
    String? definition,
    String? example,
    String? phonetic,
    String? audioUrl,
    String? videoId,
    String? videoTitle,
    Duration? timestamp,
    String? contextSentence,
    DateTime? savedAt,
    DateTime? lastReviewedAt,
    int? reviewCount,
    int? correctCount,
    double? easeFactor,
    int? interval,
    DateTime? nextReviewAt,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      phonetic: phonetic ?? this.phonetic,
      audioUrl: audioUrl ?? this.audioUrl,
      videoId: videoId ?? this.videoId,
      videoTitle: videoTitle ?? this.videoTitle,
      timestamp: timestamp ?? this.timestamp,
      contextSentence: contextSentence ?? this.contextSentence,
      savedAt: savedAt ?? this.savedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }

  /// Create from database map
  factory VocabularyWord.fromMap(Map<String, dynamic> map) {
    return VocabularyWord(
      id: map['id'] as String,
      word: map['word'] as String,
      partOfSpeech: map['part_of_speech'] as String?,
      definition: map['definition'] as String?,
      example: map['example'] as String?,
      phonetic: map['phonetic'] as String?,
      audioUrl: map['audio_url'] as String?,
      videoId: map['video_id'] as String,
      videoTitle: map['video_title'] as String?,
      timestamp: Duration(milliseconds: map['timestamp_ms'] as int? ?? 0),
      contextSentence: map['context_sentence'] as String,
      savedAt: DateTime.fromMillisecondsSinceEpoch(map['saved_at'] as int),
      lastReviewedAt: map['last_reviewed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_reviewed_at'] as int)
          : null,
      reviewCount: map['review_count'] as int? ?? 0,
      correctCount: map['correct_count'] as int? ?? 0,
      easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5,
      interval: map['interval'] as int? ?? 1,
      nextReviewAt: map['next_review_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['next_review_at'] as int)
          : null,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'part_of_speech': partOfSpeech,
      'definition': definition,
      'example': example,
      'phonetic': phonetic,
      'audio_url': audioUrl,
      'video_id': videoId,
      'video_title': videoTitle,
      'timestamp_ms': timestamp.inMilliseconds,
      'context_sentence': contextSentence,
      'saved_at': savedAt.millisecondsSinceEpoch,
      'last_reviewed_at': lastReviewedAt?.millisecondsSinceEpoch,
      'review_count': reviewCount,
      'correct_count': correctCount,
      'ease_factor': easeFactor,
      'interval': interval,
      'next_review_at': nextReviewAt?.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'VocabularyWord(word: $word, definition: $definition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VocabularyWord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
