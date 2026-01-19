/// Subtitle entry model
class SubtitleEntry {
  final int index;
  final Duration startTime;
  final Duration endTime;
  final String text;
  final List<String> words;

  SubtitleEntry({
    required this.index,
    required this.startTime,
    required this.endTime,
    required this.text,
    List<String>? words,
  }) : words = words ?? _extractWords(text);

  /// Extract individual words from subtitle text
  static List<String> _extractWords(String text) {
    // Remove HTML tags, special characters, keep only words
    final cleanText = text
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r"[^\w\s'-]"), '') // Keep letters, numbers, apostrophes, hyphens
        .trim();
    
    return cleanText
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && word.length > 1)
        .toList();
  }

  /// Check if a position falls within this subtitle's time range
  bool containsPosition(Duration position) {
    return position >= startTime && position <= endTime;
  }

  /// Duration of this subtitle
  Duration get duration => endTime - startTime;

  /// Copy with modifications
  SubtitleEntry copyWith({
    int? index,
    Duration? startTime,
    Duration? endTime,
    String? text,
    List<String>? words,
  }) {
    return SubtitleEntry(
      index: index ?? this.index,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      text: text ?? this.text,
      words: words ?? this.words,
    );
  }

  @override
  String toString() {
    return 'SubtitleEntry(index: $index, start: $startTime, end: $endTime, text: "$text")';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubtitleEntry &&
        other.index == index &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.text == text;
  }

  @override
  int get hashCode {
    return index.hashCode ^ startTime.hashCode ^ endTime.hashCode ^ text.hashCode;
  }
}
