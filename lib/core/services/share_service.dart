import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'video_processing_service.dart';

class ShareService {
  final VideoProcessingService _videoService;

  ShareService(this._videoService);

  Future<void> shareWordClip(String word, String clipPath) async {
    if (await File(clipPath).exists()) {
      await Share.shareXFiles([XFile(clipPath)], text: 'Check out this English word: $word');
    }
  }

  Future<void> shareReelOnDemand({
    required String sourcePath,
    required Duration start,
    required Duration duration,
    required String title,
    required String word,
  }) async {
    try {
      final List<XFile> filesToShare = [];
      String shareText = 'Word of the day: "$word"\nFrom: $title';

      // 1. Создаем "Постер" (скриншот с текстом)
      final posterPath = await _videoService.generateThumbnail(
        sourcePath,
        timeMs: start.inMilliseconds + (duration.inMilliseconds ~/ 2), // кадр из середины клипа
        word: word,
        contextText: title,
      );
      
      if (posterPath != null && await File(posterPath).exists()) {
        filesToShare.add(XFile(posterPath));
      }

      // 2. Подготавливаем видео
      if (!sourcePath.startsWith('http')) {
        final videoPath = await _videoService.extractClip(
          inputPath: sourcePath,
          start: start,
          duration: duration,
          outputFileName: 'reel_${DateTime.now().millisecondsSinceEpoch}.mp4',
        );
        
        if (videoPath != null && await File(videoPath).exists()) {
          filesToShare.add(XFile(videoPath));
        }
      } else {
        // Если YouTube - добавляем ссылку в текст
        final videoId = sourcePath.contains('v=') ? sourcePath.split('v=')[1].split('&')[0] : '';
        shareText += '\nWatch here: https://youtu.be/$videoId?t=${start.inSeconds}';
      }

      // 3. Шарим всё сразу
      if (filesToShare.isNotEmpty) {
        await Share.shareXFiles(filesToShare, text: shareText);
      } else {
        await Share.share(shareText);
      }
    } catch (e) {
      debugPrint('Branded share error: $e');
    }
  }
}

final shareServiceProvider = Provider<ShareService>((ref) {
  final videoService = ref.watch(videoProcessingServiceProvider);
  return ShareService(videoService);
});

