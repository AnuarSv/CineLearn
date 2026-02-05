import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/subtitle_entry.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_explode;

class YouTubeExtractorService {
  final _yt = yt_explode.YoutubeExplode();
  
  // Ключ и параметры как в проверенном Method 1
  static const String _innerTubeKey = "AIzaSyAO_FJ2Sl_Anp3_SAtI8m_n6Eq_d0Eq_d0";
  static const String _playerApiUrl = "https://www.youtube.com/youtubei/v1/player?key=$_innerTubeKey";

  Future<YouTubeVideoData> extractData(String videoId, {String? manualSubsUrl}) async {
    try {
      // 1. Потоки через youtube_explode
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.muxed.sortByVideoQuality().last;
      final videoUrl = streamInfo.url.toString();
      final videoMeta = await _yt.videos.get(videoId);

      List<SubtitleEntry> subtitles = [];
      
      // 2. Если есть ссылка от сниффера - пробуем её
      if (manualSubsUrl != null && manualSubsUrl.isNotEmpty) {
        subtitles = await _fetchSubtitlesFromDirectUrl(manualSubsUrl);
      }

      // 3. Если нет - используем наш ПОБЕДНЫЙ метод (Android Client)
      if (subtitles.isEmpty) {
        subtitles = await _fetchSubtitlesInnerTubeAndroid(videoId);
      }

      return YouTubeVideoData(
        videoUrl: videoUrl,
        subtitles: subtitles,
        title: videoMeta.title,
      );
    } catch (e) {
      print('Final YouTube Extractor Error: $e');
      rethrow;
    }
  }

  Future<List<SubtitleEntry>> _fetchSubtitlesInnerTubeAndroid(String videoId) async {
    final List<SubtitleEntry> entries = [];
    try {
      // Имитируем запрос от Android-приложения (версия 19.05.35)
      final payload = {
        "videoId": videoId,
        "context": {
          "client": {
            "clientName": "ANDROID",
            "clientVersion": "19.05.35",
            "hl": "en",
            "gl": "US"
          }
        }
      };

      final response = await http.post(
        Uri.parse(_playerApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'com.google.android.youtube/19.05.35 (Linux; U; Android 14)',
        },
        body: json.encode(payload),
      );

      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final captions = data['captions']?['playerCaptionsTracklistRenderer']?['captionTracks'];
      
      if (captions == null || captions is! List) return [];

      // Приоритет: английский (не авто), потом любой английский
      var track = captions.firstWhere(
        (t) => t['languageCode'] == 'en' && t['kind'] != 'asr',
        orElse: () => captions.firstWhere(
          (t) => t['languageCode'].toString().startsWith('en'),
          orElse: () => null,
        ),
      );

      if (track != null) {
        return await _fetchSubtitlesFromDirectUrl(track['baseUrl']);
      }
    } catch (e) {
      print('InnerTube Android Fetch Error: $e');
    }
    return entries;
  }

  Future<List<SubtitleEntry>> _fetchSubtitlesFromDirectUrl(String url) async {
    final List<SubtitleEntry> entries = [];
    try {
      // YouTube отдает JSON3 только если добавить fmt=json3
      final finalUrl = url.contains('fmt=') ? url : '$url&fmt=json3';
      final response = await http.get(Uri.parse(finalUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = data['events'] as List?;
        if (events != null) {
          int index = 0;
          for (var event in events) {
            if (event['segs'] == null) continue;
            final start = event['tStartMs'] as int;
            final dur = event['dDurationMs'] as int? ?? 0;
            final text = (event['segs'] as List).map((s) => s['utf8']).join('').trim();
            if (text.isEmpty) continue;
            entries.add(SubtitleEntry(
              index: index++,
              startTime: Duration(milliseconds: start),
              endTime: Duration(milliseconds: start + dur),
              text: text,
            ));
          }
        }
      }
    } catch (e) {
      print('Direct subtitle URL fetch failed: $e');
    }
    return entries;
  }

  Future<bool> hasEnglishSubtitles(String videoId) async {
    // Быстрая проверка тем же методом
    try {
      final payload = {
        "videoId": videoId,
        "context": {"client": {"clientName": "ANDROID", "clientVersion": "19.05.35"}}
      };
      final res = await http.post(Uri.parse(_playerApiUrl), body: json.encode(payload));
      return res.body.contains('"languageCode":"en"');
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _yt.close();
  }
}

class YouTubeVideoData {
  final String videoUrl;
  final List<SubtitleEntry> subtitles;
  final String title;

  YouTubeVideoData({
    required this.videoUrl,
    required this.subtitles,
    required this.title,
  });
}