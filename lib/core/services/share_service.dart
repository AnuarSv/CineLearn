import 'dart:io';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareService {
  Future<void> shareText(String text) async {
    await Share.share(text);
  }

  Future<void> shareFile(String filePath, {String? text}) async {
    final file = XFile(filePath);
    await Share.shareXFiles([file], text: text);
  }

  /// Placeholder: In a real app this would overlay text on an image
  /// For now, we mock it by returning the original image or a generated placeholder
  Future<void> shareReelCard(String word, String definition, String imagePath) async {
    // Determine the path to share
    String path = imagePath;
    
    // If the image path doesn't exist, we might want to generate a text-based image,
    // but for simplicity in this iteration, we'll share the text if image is missing,
    // or share the file if present.
    
    if (await File(path).exists()) {
      await Share.shareXFiles(
        [XFile(path)],
        text: 'Learn "$word" with CineLearn!\n\nDefinition: $definition',
      );
    } else {
      await Share.share('Learn "$word" with CineLearn!\n\nDefinition: $definition');
    }
  }
}

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});
