import 'dart:convert';
import 'package:http/http.dart' as http;


class OxfordDictionaryService {
  // Using free dictionary API for demonstration/stability as verified Oxford credentials are required
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  Future<WordDefinition?> lookupWord(String word) async {
    try {
      final cleanWord = _cleanWord(word);
      final response = await http.get(
        Uri.parse('$_baseUrl/$cleanWord'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return WordDefinition.fromFreeApiJson(data.first);
        }
      } else if (response.statusCode == 404) {
        return null; 
      }
      
      return null;
    } catch (e) {
      print('Dictionary lookup error: $e');
      return null;
    }
  }

  String _cleanWord(String word) {
    return word.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
  }

  void dispose() {}
}

class WordDefinition {
  final String word;
  final String definition;
  final String? example;
  final String? partOfSpeech;
  final String? phonetic;
  final String? audioUrl;
  final List<String> synonyms;

  WordDefinition({
    required this.word,
    required this.definition,
    this.example,
    this.partOfSpeech,
    this.phonetic,
    this.audioUrl,
    this.synonyms = const [],
  });

  factory WordDefinition.fromFreeApiJson(Map<String, dynamic> json) {
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

    return WordDefinition(
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
