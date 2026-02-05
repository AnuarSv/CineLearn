// Mock SubtitleTrack to replace FFmpeg dependency
class SubtitleTrack {
  final int index;
  final String? language;
  final String? title;

  SubtitleTrack({required this.index, this.language, this.title});
}
