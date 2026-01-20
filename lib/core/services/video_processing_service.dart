import 'dart:io';
import 'dart:convert';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class SubtitleTrack {
  final int index;
  final String? language;
  final String? title;

  SubtitleTrack({required this.index, this.language, this.title});

  @override
  String toString() => 'Track $index: ${language ?? "unknown"} ${title != null ? "($title)" : ""}';
}

class VideoProcessingService {
  Future<List<SubtitleTrack>> getSubtitleTracks(String videoPath) async {
    try {
      final session = await FFprobeKit.execute(
        '-v error -select_streams s -show_entries stream=index:stream_tags=language,title -of json "$videoPath"'
      );
      final output = await session.getOutput();
      
      if (output == null || output.isEmpty) return [];

      final data = json.decode(output);
      final streams = data['streams'] as List<dynamic>? ?? [];
      
      return streams.map((s) {
        final tags = s['tags'] as Map<String, dynamic>?;
        return SubtitleTrack(
          index: s['index'],
          language: tags?['language'],
          title: tags?['title'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error probing subtitle tracks: $e');
      return [];
    }
  }

  Future<String?> extractSubtitleTrack(String videoPath, int trackIndex) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/subtitle_${DateTime.now().millisecondsSinceEpoch}.srt';
      
      // Extract specific subtitle stream to srt
      final session = await FFmpegKit.execute(
        '-i "$videoPath" -map 0:$trackIndex "$outputPath"'
      );
      
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        debugPrint('FFmpeg extraction failed with code: $returnCode');
        return null;
      }
    } catch (e) {
      debugPrint('Error extracting subtitle: $e');
      return null;
    }
  }

  Future<String?> generateThumbnail(String videoPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir = Directory('${appDir.path}/thumbnails');
      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
      }
      
      final outputPath = '${thumbnailsDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Extract frame at 1 second mark (or 0 if video is very short)
      final session = await FFmpegKit.execute(
        '-ss 00:00:01 -i "$videoPath" -vframes 1 -q:v 2 "$outputPath"'
      );
      
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<String?> extractClip({
    required String inputPath,
    required Duration start,
    required Duration duration,
    required String outputFileName,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final clipsDir = Directory('${appDir.path}/clips');
      if (!await clipsDir.exists()) {
        await clipsDir.create(recursive: true);
      }
      
      final outputPath = '${clipsDir.path}/$outputFileName';
      
      final startTime = _formatDuration(start);
      final durationTime = _formatDuration(duration);
      
      // Encode with faster preset for clips to ensure they are small and load fast
      final session = await FFmpegKit.execute(
        '-ss $startTime -i "$inputPath" -t $durationTime -c:v libx264 -preset superfast -crf 28 -c:a aac -b:a 128k "$outputPath"'
      );
      
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error extracting clip: $e');
      return null;
    }
  }

  Future<void> deleteClip(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
