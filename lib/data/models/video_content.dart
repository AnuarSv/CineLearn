/// Video content model
class VideoContent {
  final String id;
  final String title;
  final String filePath;
  final String? subtitlePath;
  final String? thumbnailPath;
  final Duration duration;
  final DateTime addedAt;
  final DateTime? lastPlayedAt;
  final Duration lastPosition;
  final int savedWordsCount;

  VideoContent({
    required this.id,
    required this.title,
    required this.filePath,
    this.subtitlePath,
    this.thumbnailPath,
    required this.duration,
    required this.addedAt,
    this.lastPlayedAt,
    this.lastPosition = Duration.zero,
    this.savedWordsCount = 0,
  });

  /// Check if video has subtitles loaded
  bool get hasSubtitles => subtitlePath != null && subtitlePath!.isNotEmpty;

  /// Progress percentage (0.0 - 1.0)
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return lastPosition.inMilliseconds / duration.inMilliseconds;
  }

  /// Human readable duration string
  String get durationString {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Copy with modifications
  VideoContent copyWith({
    String? id,
    String? title,
    String? filePath,
    String? subtitlePath,
    String? thumbnailPath,
    Duration? duration,
    DateTime? addedAt,
    DateTime? lastPlayedAt,
    Duration? lastPosition,
    int? savedWordsCount,
  }) {
    return VideoContent(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      subtitlePath: subtitlePath ?? this.subtitlePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      duration: duration ?? this.duration,
      addedAt: addedAt ?? this.addedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      lastPosition: lastPosition ?? this.lastPosition,
      savedWordsCount: savedWordsCount ?? this.savedWordsCount,
    );
  }

  /// Create from database map
  factory VideoContent.fromMap(Map<String, dynamic> map) {
    return VideoContent(
      id: map['id'] as String,
      title: map['title'] as String,
      filePath: map['file_path'] as String,
      subtitlePath: map['subtitle_path'] as String?,
      thumbnailPath: map['thumbnail_path'] as String?,
      duration: Duration(milliseconds: map['duration_ms'] as int? ?? 0),
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['added_at'] as int),
      lastPlayedAt: map['last_played_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_played_at'] as int)
          : null,
      lastPosition: Duration(milliseconds: map['last_position_ms'] as int? ?? 0),
      savedWordsCount: map['saved_words_count'] as int? ?? 0,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'subtitle_path': subtitlePath,
      'thumbnail_path': thumbnailPath,
      'duration_ms': duration.inMilliseconds,
      'added_at': addedAt.millisecondsSinceEpoch,
      'last_played_at': lastPlayedAt?.millisecondsSinceEpoch,
      'last_position_ms': lastPosition.inMilliseconds,
      'saved_words_count': savedWordsCount,
    };
  }

  @override
  String toString() {
    return 'VideoContent(id: $id, title: $title, duration: $durationString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoContent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
