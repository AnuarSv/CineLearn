import 'dart:io';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:file_picker/file_picker.dart';
import '../providers/providers.dart';

class ShareService {
  final VideoProcessingService _videoService;
  
  ShareService(this._videoService);

  Future<void> shareText(String text) async {
    await Share.share(text);
  }

  Future<void> shareFile(String filePath, {String? text}) async {
    final file = XFile(filePath);
    await Share.shareXFiles([file], text: text);
  }

  /// Extracts a clip on demand and shares it
  Future<void> shareReelOnDemand({
    required String sourcePath,
    required Duration start,
    required Duration duration,
    required String title,
    required String word,
  }) async {
    try {
      // 1. Generate a temporary clip
      final clipPath = await _videoService.extractClip(
        inputPath: sourcePath,
        start: start,
        duration: duration,
        outputFileName: 'share_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      if (clipPath != null) {
        // 2. Share the file
        await Share.shareXFiles(
          [XFile(clipPath)],
          text: 'Check out this word "$word" from "$title" on CineLearn!',
        );
      }
    } catch (e) {
      print('Error sharing reel: $e');
      // Fallback
      await Share.share('Learn "$word" with CineLearn!');
    }
  }
}

final shareServiceProvider = Provider<ShareService>((ref) {
  final videoService = ref.read(videoProcessingServiceProvider);
  return ShareService(videoService);
});
