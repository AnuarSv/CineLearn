import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Videos table - stores uploaded video metadata
class Videos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get filePath => text()();
  TextColumn get subtitlePath => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get addedAt => integer()();
  IntColumn get lastPlayedAt => integer().nullable()();
  IntColumn get lastPositionMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Subtitles table - stores parsed SRT entries for each video
class Subtitles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get videoId => text()();
  IntColumn get subtitleIndex => integer()();
  IntColumn get startTimeMs => integer()();
  IntColumn get endTimeMs => integer()();
  TextColumn get content => text()();
}

/// Vocabulary table - stores saved words with definitions
class VocabularyWords extends Table {
  TextColumn get id => text()();
  TextColumn get word => text()();
  TextColumn get partOfSpeech => text().nullable()();
  TextColumn get definition => text().nullable()();
  TextColumn get example => text().nullable()();
  TextColumn get phonetic => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  TextColumn get videoId => text()();
  TextColumn get videoTitle => text().nullable()();
  IntColumn get timestampMs => integer()();
  TextColumn get contextSentence => text()();
  IntColumn get savedAt => integer()();
  IntColumn get lastReviewedAt => integer().nullable()();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get intervalDays => integer().withDefault(const Constant(1))();
  IntColumn get nextReviewAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Review clips table - pre-generated video clips for reels
class ReviewClips extends Table {
  TextColumn get id => text()();
  TextColumn get vocabularyId => text()();
  TextColumn get videoId => text()();
  IntColumn get clipStartMs => integer()();
  IntColumn get clipEndMs => integer()();
  TextColumn get clipPath => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// App settings table
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Cached dictionary definitions - local cache for API responses
class CachedDefinitions extends Table {
  TextColumn get word => text()();
  TextColumn get definition => text()();
  TextColumn get partOfSpeech => text().nullable()();
  TextColumn get phonetic => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  TextColumn get example => text().nullable()();
  TextColumn get synonyms => text().nullable()(); // JSON array string
  IntColumn get cachedAt => integer()();

  @override
  Set<Column> get primaryKey => {word};
}

@DriftDatabase(tables: [Videos, Subtitles, VocabularyWords, ReviewClips, AppSettings, CachedDefinitions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(cachedDefinitions);
      }
    },
  );

  // ============ VIDEO OPERATIONS ============

  /// Get all videos
  Future<List<Video>> getAllVideos() => select(videos).get();

  /// Watch all videos
  Stream<List<Video>> watchAllVideos() {
    return (select(videos)
          ..orderBy([
            (t) => OrderingTerm(expression: t.addedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Get videos sorted by last played
  Future<List<Video>> getRecentVideos() {
    return (select(videos)
          ..orderBy([
            (t) => OrderingTerm(expression: t.lastPlayedAt, mode: OrderingMode.desc),
          ])
          ..limit(10))
        .get();
  }

  /// Watch recent videos for real-time updates
  Stream<List<Video>> watchRecentVideos() {
    return (select(videos)
          ..orderBy([
            (t) => OrderingTerm(expression: t.lastPlayedAt, mode: OrderingMode.desc),
          ])
          ..limit(10))
        .watch();
  }

  /// Insert or update a video
  Future<void> upsertVideo(VideosCompanion video) {
    return into(videos).insertOnConflictUpdate(video);
  }

  /// Update video position
  Future<void> updateVideoPosition(String videoId, int positionMs) {
    return (update(videos)..where((t) => t.id.equals(videoId))).write(
      VideosCompanion(
        lastPositionMs: Value(positionMs),
        lastPlayedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Delete a video and its related data
  Future<void> deleteVideo(String videoId) async {
    await (delete(subtitles)..where((t) => t.videoId.equals(videoId))).go();
    await (delete(reviewClips)..where((t) => t.videoId.equals(videoId))).go();
    await (delete(vocabularyWords)..where((t) => t.videoId.equals(videoId))).go();
    await (delete(videos)..where((t) => t.id.equals(videoId))).go();
  }

  // ============ SUBTITLE OPERATIONS ============

  /// Insert subtitles for a video
  Future<void> insertSubtitles(String videoId, List<SubtitlesCompanion> subs) async {
    await batch((batch) {
      batch.insertAll(subtitles, subs);
    });
  }

  /// Get subtitles for a video
  Future<List<Subtitle>> getSubtitlesForVideo(String videoId) {
    return (select(subtitles)
          ..where((t) => t.videoId.equals(videoId))
          ..orderBy([(t) => OrderingTerm.asc(t.startTimeMs)]))
        .get();
  }

  /// Delete subtitles for a video
  Future<void> deleteSubtitlesForVideo(String videoId) {
    return (delete(subtitles)..where((t) => t.videoId.equals(videoId))).go();
  }

  // ============ VOCABULARY OPERATIONS ============

  /// Get all vocabulary words
  Future<List<VocabularyWord>> getAllVocabulary() {
    return (select(vocabularyWords)
          ..orderBy([(t) => OrderingTerm.desc(t.savedAt)]))
        .get();
  }

  /// Get vocabulary words due for review
  Future<List<VocabularyWord>> getDueForReview() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (select(vocabularyWords)
          ..where((t) => t.nextReviewAt.isNull() | t.nextReviewAt.isSmallerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)]))
        .get();
  }

  /// Get vocabulary for a specific video
  Future<List<VocabularyWord>> getVocabularyForVideo(String videoId) {
    return (select(vocabularyWords)
          ..where((t) => t.videoId.equals(videoId))
          ..orderBy([(t) => OrderingTerm.asc(t.timestampMs)]))
        .get();
  }

  /// Insert or update vocabulary word
  Future<void> upsertVocabularyWord(VocabularyWordsCompanion word) {
    return into(vocabularyWords).insertOnConflictUpdate(word);
  }

  /// Delete vocabulary word
  Future<void> deleteVocabularyWord(String id) {
    return (delete(vocabularyWords)..where((t) => t.id.equals(id))).go();
  }

  /// Count vocabulary words
  Future<int> countVocabulary() async {
    final count = vocabularyWords.id.count();
    final query = selectOnly(vocabularyWords)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Count vocabulary saved today
  Future<int> countVocabularySavedToday() async {
    final startOfDay = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    final count = vocabularyWords.id.count();
    final query = selectOnly(vocabularyWords)
      ..addColumns([count])
      ..where(vocabularyWords.savedAt.isBiggerOrEqualValue(startOfDay.millisecondsSinceEpoch));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ============ SETTINGS OPERATIONS ============

  /// Get a setting value
  Future<String?> getSetting(String key) async {
    final result = await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  /// Set a setting value
  Future<void> setSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }
}

/// Open SQLite database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cinelearn.db'));
    return NativeDatabase.createInBackground(file);
  });
}
