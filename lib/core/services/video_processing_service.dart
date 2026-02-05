import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/subtitle_track.dart';

class VideoProcessingService {
  static const _channel = MethodChannel('com.cinelearn.cinelearn/video_tools');

  /// Сверхбыстрая нарезка видео без перекодирования (MediaMuxer)
  Future<String?> extractClip({
    required String inputPath,
    required Duration start,
    required Duration duration,
    required String outputFileName,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/$outputFileName';
      
      final File file = File(outputPath);
      if (await file.exists()) await file.delete();

      final String? result = await _channel.invokeMethod('trimVideo', {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'startMs': start.inMilliseconds,
        'durationMs': duration.inMilliseconds,
      });
      
      return result;
    } catch (e) {
      print('Native Trim Error: $e');
      return null;
    }
  }

  /// Получение превью-кадра из видео (с наложением текста)
  Future<String?> generateThumbnail(String videoPath, {int? timeMs, String? word, String? contextText}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final String? result = await _channel.invokeMethod('getThumbnail', {
        'videoPath': videoPath,
        'outputPath': outputPath,
        'timeMs': timeMs ?? 1000,
        'word': word,
        'context': contextText,
      });
      return result;
    } catch (e) {
      print('Thumbnail Error: $e');
      return null;
    }
  }

  // Заглушки для треков (обычно не нужны для YouTube)
  Future<List<SubtitleTrack>> getSubtitleTracks(String videoPath) async => [];
  Future<String?> extractSubtitleTrack(String videoPath, int trackIndex) async => null;
}

final videoProcessingServiceProvider = Provider((ref) => VideoProcessingService());
