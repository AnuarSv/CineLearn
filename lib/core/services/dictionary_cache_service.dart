import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../../data/database/app_database.dart';

/// Service that caches dictionary lookups locally for offline access and speed
class DictionaryCacheService {
  final AppDatabase _db;
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  DictionaryCacheService(this._db);

  /// Look up a word - checks cache first, then fetches from API
  Future<CachedWordDefinition?> lookupWord(String word) async {
    final cleanWord = _cleanWord(word);
    
    // 1. Check local cache
    final cached = await _getFromCache(cleanWord);
    if (cached != null) {
      return cached;
    }

    // 2. Fetch from API
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$cleanWord'),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final definition = CachedWordDefinition.fromApiJson(data.first);
          
          // 3. Save to cache
          await _saveToCache(definition);
          
          return definition;
        }
      }
      return null;
    } catch (e) {
      // Network error - return null
      return null;
    }
  }

  Future<CachedWordDefinition?> _getFromCache(String word) async {
    final result = await (_db.select(_db.cachedDefinitions)
          ..where((t) => t.word.equals(word)))
        .getSingleOrNull();

    if (result != null) {
      return CachedWordDefinition(
        word: result.word,
        definition: result.definition,
        partOfSpeech: result.partOfSpeech,
        phonetic: result.phonetic,
        audioUrl: result.audioUrl,
        example: result.example,
        synonyms: result.synonyms != null
            ? (json.decode(result.synonyms!) as List).cast<String>()
            : [],
      );
    }
    return null;
  }

  Future<void> _saveToCache(CachedWordDefinition definition) async {
    await _db.into(_db.cachedDefinitions).insertOnConflictUpdate(
          CachedDefinitionsCompanion(
            word: Value(definition.word.toLowerCase()),
            definition: Value(definition.definition),
            partOfSpeech: Value(definition.partOfSpeech),
            phonetic: Value(definition.phonetic),
            audioUrl: Value(definition.audioUrl),
            example: Value(definition.example),
            synonyms: Value(json.encode(definition.synonyms)),
            cachedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  String _cleanWord(String word) {
    return word.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
  }
}

/// Cached word definition model
class CachedWordDefinition {
  final String word;
  final String definition;
  final String? partOfSpeech;
  final String? phonetic;
  final String? audioUrl;
  final String? example;
  final List<String> synonyms;

  CachedWordDefinition({
    required this.word,
    required this.definition,
    this.partOfSpeech,
    this.phonetic,
    this.audioUrl,
    this.example,
    this.synonyms = const [],
  });

  factory CachedWordDefinition.fromApiJson(Map<String, dynamic> json) {
    final meanings = (json['meanings'] as List?)?.isNotEmpty == true
        ? json['meanings'][0]
        : null;

    final definitionObj = (meanings?['definitions'] as List?)?.isNotEmpty == true
        ? meanings['definitions'][0]
        : null;

    final phonetics = json['phonetics'] as List?;
    String? audio;
    if (phonetics != null) {
      for (var p in phonetics) {
        if (p['audio'] != null && p['audio'].toString().isNotEmpty) {
          audio = p['audio'];
          break;
        }
      }
    }

    return CachedWordDefinition(
      word: json['word'] ?? '',
      definition: definitionObj?['definition'] ?? 'No definition found.',
      example: definitionObj?['example'],
      partOfSpeech: meanings?['partOfSpeech'],
      phonetic: json['phonetic'],
      audioUrl: audio,
      synonyms: (meanings?['synonyms'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  String get pronunciationDisplay => phonetic ?? '';
}
