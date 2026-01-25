import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:drift/drift.dart' as drift;

import 'package:uuid/uuid.dart';
import '../../../app/theme/colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart' as db;
import '../../../data/models/subtitle_entry.dart';
import '../../../data/models/vocabulary_word.dart' as model; // Manual model
import '../widgets/subtitle_overlay.dart';
import '../widgets/word_popup.dart';
import '../../../app/widgets/glass_container.dart';

/// Video player screen with custom gesture controls
class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;

  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  
  db.Video? _videoData;
  List<SubtitleEntry> _subtitles = [];
  SubtitleEntry? _currentSubtitle;
  
  bool _isLoading = true;
  bool _showControls = true;
  bool _showSubtitleOverlay = false;
  
  // For auto-hiding controls
  DateTime? _lastInteraction;
  static const _controlsHideDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    // Allow all orientations usage
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadData();
  }

  @override
  void dispose() {
    // Reset to portrait only when leaving player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller?.removeListener(_onVideoPositionChanged);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final database = ref.read(databaseProvider);
    final video = await (database.select(database.videos)
      ..where((t) => t.id.equals(widget.videoId))).getSingleOrNull();

    if (video == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video not found')),
        );
        context.go('/home');
      }
      return;
    }

    setState(() => _videoData = video);

    // Load subtitles
    final dbSubs = await database.getSubtitlesForVideo(video.id);
    if (mounted && dbSubs.isNotEmpty) {
      setState(() {
        _subtitles = dbSubs.map((s) => SubtitleEntry(
          index: s.subtitleIndex,
          startTime: Duration(milliseconds: s.startTimeMs),
          endTime: Duration(milliseconds: s.endTimeMs),
          text: s.content,
        )).toList();
      });
    }

    // Initialize video
    final file = File(video.filePath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video file not found on device')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    _controller = VideoPlayerController.file(file);
    await _controller!.initialize();
    
    // Seek to last position
    if (video.lastPositionMs > 0) {
      await _controller!.seekTo(Duration(milliseconds: video.lastPositionMs));
    }

    _controller!.addListener(_onVideoPositionChanged);
    _controller!.play();

    if (mounted) {
      setState(() => _isLoading = false);
      _startControlsTimer();
    }
  }

  void _onVideoPositionChanged() {
    if (_controller == null || !_controller!.value.isInitialized || !mounted) return;

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    // Update current subtitle
    _updateCurrentSubtitle(position);

    // Save progress every 10 seconds
    if (position.inSeconds % 10 == 0 && _videoData != null) {
      ref.read(databaseProvider).updateVideoPosition(_videoData!.id, position.inMilliseconds);
    }

    // Update duration if not set
    if (_videoData != null && _videoData!.durationMs == 0 && duration > Duration.zero) {
      ref.read(databaseProvider).upsertVideo(db.VideosCompanion(
        id: drift.Value(_videoData!.id),
        durationMs: drift.Value(duration.inMilliseconds),
      ));
    }
  }

  void _updateCurrentSubtitle(Duration position) {
    if (_subtitles.isEmpty) return;
    
    final srtParser = ref.read(srtParserServiceProvider);
    final subtitle = srtParser.findAtPosition(_subtitles, position);
    
    if (subtitle != _currentSubtitle && mounted) {
      setState(() => _currentSubtitle = subtitle);
    }
  }

  void _startControlsTimer() {
    _lastInteraction = DateTime.now();
    Future.delayed(_controlsHideDelay, () {
      if (mounted && _lastInteraction != null) {
        final elapsed = DateTime.now().difference(_lastInteraction!);
        if (elapsed >= _controlsHideDelay && _showControls && !_showSubtitleOverlay) {
          setState(() => _showControls = false);
        }
      }
    });
  }

  void _onTap() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startControlsTimer();
      }
    });
  }

  void _onDoubleTap() {
    if (_controller == null) return;
    
    if (_subtitles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No subtitles available'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _controller!.pause();
    
    // Find closest subtitle if current is null
    if (_currentSubtitle == null) {
      final srtParser = ref.read(srtParserServiceProvider);
      _currentSubtitle = srtParser.findClosestToPosition(_subtitles, _controller!.value.position);
    }
    
    setState(() {
      _showSubtitleOverlay = true;
      _showControls = false;
    });
  }

  void _hideSubtitleOverlay() {
    setState(() => _showSubtitleOverlay = false);
    _controller?.play();
  }

  void _seekForward() {
    if (_controller == null) return;
    final newPosition = _controller!.value.position + const Duration(seconds: 10);
    _controller!.seekTo(newPosition);
    _lastInteraction = DateTime.now();
  }

  void _seekBackward() {
    if (_controller == null) return;
    final newPosition = _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
    _lastInteraction = DateTime.now();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    _lastInteraction = DateTime.now();
    setState(() {});
  }

  // Triggered when user taps a word in the SubtitleOverlay
  void _onWordTapped(String word) {
    if (_videoData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WordPopup(
        word: word,
        contextSentence: _currentSubtitle?.text ?? '',
        timestamp: _controller!.value.position,
        videoId: _videoData!.id,
        cacheService: ref.read(dictionaryCacheServiceProvider),
        onClose: () => Navigator.pop(context),
        onSave: (wordObj) => _onSaveWord(wordObj),
      ),
    );
  }

  // Callback from WordPopup to save the word
  Future<void> _onSaveWord(model.VocabularyWord wordObj) async {
    try {
      final database = ref.read(databaseProvider);
      
      final entry = db.VocabularyWordsCompanion(
        id: drift.Value(wordObj.id),
        word: drift.Value(wordObj.word.toLowerCase()),
        definition: drift.Value(wordObj.definition),
        partOfSpeech: drift.Value(wordObj.partOfSpeech),
        phonetic: drift.Value(wordObj.phonetic),
        audioUrl: drift.Value(wordObj.audioUrl),
        example: drift.Value(wordObj.example),
        videoId: drift.Value(wordObj.videoId),
        videoTitle: drift.Value(_videoData?.title ?? wordObj.videoTitle),
        timestampMs: drift.Value(wordObj.timestamp.inMilliseconds),
        contextSentence: drift.Value(wordObj.contextSentence),
        savedAt: drift.Value(wordObj.savedAt.millisecondsSinceEpoch),
      );

      await database.upsertVocabularyWord(entry);

      // 1. Create a ReviewClip entry (logical)
      final clipId = const Uuid().v4();
      final startTimeMs = (wordObj.timestamp.inMilliseconds - 5000).clamp(0, 10000000).toInt();
      final endTimeMs = (wordObj.timestamp.inMilliseconds + 5000);
      
      await database.into(database.reviewClips).insert(db.ReviewClipsCompanion(
        id: drift.Value(clipId),
        vocabularyId: drift.Value(wordObj.id),
        videoId: drift.Value(wordObj.videoId),
        clipStartMs: drift.Value(startTimeMs),
        clipEndMs: drift.Value(endTimeMs),
        createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      ));

      // 2. Physical extraction disabled per user request ("don't copy")
      // We will rely on logical clipping (playing original file from startMs to endMs)
      // This makes saving instant without FFmpeg processing overhead.
      // _extractPhysicalClip(clipId, wordObj.videoId, startTimeMs, endTimeMs);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved: ${wordObj.word}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving word: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save word: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _exit() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showSubtitleOverlay,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showSubtitleOverlay) {
          _hideSubtitleOverlay();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _controller == null || !_controller!.value.isInitialized
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                        const SizedBox(height: 16),
                        const Text('Failed to load video', style: TextStyle(color: Colors.white54)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _exit,
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: _showSubtitleOverlay ? null : _onTap,
                    onDoubleTap: _showSubtitleOverlay ? null : _onDoubleTap,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Video
                        Center(
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                        ),

                        // Controls overlay
                        if (!_showSubtitleOverlay)
                          IgnorePointer(
                            ignoring: !_showControls,
                            child: _buildControlsOverlay(),
                          ),

                        // Subtitle overlay for word selection
                        if (_showSubtitleOverlay && _currentSubtitle != null)
                          SubtitleOverlay(
                            subtitle: _currentSubtitle!,
                            onWordTap: _onWordTapped,
                            onDismiss: _hideSubtitleOverlay,
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final isPlaying = _controller!.value.isPlaying;

    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: SafeArea(
        child: Stack(
          children: [
            // Top bar
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
                opacity: 0.4,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _exit,
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _videoData?.title ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Center controls
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   // Seek backward
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.black,
                    opacity: 0.3,
                    child: IconButton(
                      onPressed: _seekBackward,
                      iconSize: 32,
                      icon: const Icon(Icons.replay_10, color: AppColors.success),
                      tooltip: 'Rewind 10s',
                    ),
                  ),
                  const SizedBox(width: 32),
                  
                  // Play/Pause
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.success.withOpacity(0.5), blurRadius: 25),
                        ],
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 32),

                  // Seek forward
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.black,
                    opacity: 0.3,
                    child: IconButton(
                      onPressed: _seekForward,
                      iconSize: 32,
                      icon: const Icon(Icons.forward_10, color: AppColors.success),
                      tooltip: 'Forward 10s',
                    ),
                  ),
                ],
              ),
            ),

            // Bottom bar with progress
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(24),
                color: Colors.black,
                opacity: 0.4,
                child: Column(
                  children: [
                    // Progress bar
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.success, // Green as requested
                        inactiveTrackColor: Colors.white24,
                        thumbColor: AppColors.success,
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      ),
                      child: Slider(
                        value: position.inMilliseconds.toDouble(),
                        min: 0,
                        max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                        onChanged: (value) {
                          _controller!.seekTo(Duration(milliseconds: value.toInt()));
                          _lastInteraction = DateTime.now();
                        },
                      ),
                    ),
                    // Time labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _extractPhysicalClip(String clipId, String videoId, int startMs, int endMs) async {
    try {
      final database = ref.read(databaseProvider);
      final videoService = ref.read(videoProcessingServiceProvider);
      
      final video = await (database.select(database.videos)..where((t) => t.id.equals(videoId))).getSingleOrNull();
      if (video == null) return;

      final outputPath = await videoService.extractClip(
        inputPath: video.filePath,
        start: Duration(milliseconds: startMs),
        duration: Duration(milliseconds: endMs - startMs),
        outputFileName: 'clip_$clipId.mp4',
      );

      if (outputPath != null) {
        await (database.update(database.reviewClips)..where((t) => t.id.equals(clipId))).write(
          db.ReviewClipsCompanion(
            clipPath: drift.Value(outputPath),
          ),
        );
        debugPrint('Physical clip extracted: $outputPath');
      }
    } catch (e) {
      debugPrint('Error extracting physical clip: $e');
    }
  }
}
