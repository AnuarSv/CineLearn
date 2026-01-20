import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../services/oxford_dictionary_service.dart';
import '../services/dictionary_cache_service.dart';
import '../services/srt_parser_service.dart';
import '../services/video_processing_service.dart';

/// Provider for the AppDatabase instance
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provider for the OxfordDictionaryService (legacy, for compatibility)
final dictionaryServiceProvider = Provider<OxfordDictionaryService>((ref) {
  final service = OxfordDictionaryService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the cached DictionaryCacheService (preferred - uses local cache)
final dictionaryCacheServiceProvider = Provider<DictionaryCacheService>((ref) {
  final db = ref.watch(databaseProvider);
  return DictionaryCacheService(db);
});

/// Provider for the SrtParserService
final srtParserServiceProvider = Provider<SrtParserService>((ref) {
  return SrtParserService();
});

/// Provider for the VideoProcessingService
final videoProcessingServiceProvider = Provider<VideoProcessingService>((ref) {
  return VideoProcessingService();
});

/// Provider for the list of all videos
final videosStreamProvider = StreamProvider<List<Video>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllVideos();
});

/// Provider for the list of recent videos
final recentVideosProvider = FutureProvider<List<Video>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getRecentVideos();
});

/// Provider for the list of all vocabulary words
final vocabularyStreamProvider = StreamProvider<List<VocabularyWord>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.vocabularyWords)
        ..orderBy([(t) => OrderingTerm(expression: t.savedAt, mode: OrderingMode.desc)]))
      .watch();
});

/// Provider for the count of total vocabulary words
final vocabularyCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.countVocabulary().asStream();
});

/// Provider for due vocabulary words
final dueVocabularyProvider = FutureProvider<List<VocabularyWord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getDueForReview();
});
