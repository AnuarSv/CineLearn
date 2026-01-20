import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:drift/drift.dart' as drift;

import '../../../app/theme/colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart' as db;
import '../../../data/models/subtitle_entry.dart';
import '../../../data/models/vocabulary_word.dart' as model; // Manual model
import '../widgets/subtitle_overlay.dart';
import '../widgets/word_popup.dart';

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
        dictionaryService: ref.read(dictionaryServiceProvider),
        onClose: () => Navigator.pop(context),
        onSave: (wordObj) => _onSaveWord(wordObj),
      ),
    );
  }

  // Callback from WordPopup to save the word
  Future<void> _onSaveWord(model.VocabularyWord wordObj) async {
    final database = ref.read(databaseProvider);
    
    final entry = db.VocabularyWordsCompanion(
      id: drift.Value(wordObj.id),
      word: drift.Value(wordObj.word.toLowerCase()), // normalize
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

    if (mounted) {
      Navigator.pop(context); // Close popup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved: ${wordObj.word}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
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
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video
                      GestureDetector(
                        onTap: _onTap,
                        onDoubleTap: _onDoubleTap,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
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
    );
  }

  Widget _buildControlsOverlay() {
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final isPlaying = _controller!.value.isPlaying;

    return GestureDetector(
      onTap: _onTap,
      onDoubleTap: _onDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _exit,
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _videoData?.title ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Center controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Seek backward
                  IconButton(
                    onPressed: _seekBackward,
                    iconSize: 48,
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                  ),
                  const SizedBox(width: 32),
                  // Play/Pause
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Seek forward
                  IconButton(
                    onPressed: _seekForward,
                    iconSize: 48,
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                  ),
                ],
              ),

              const Spacer(),

              // Bottom bar with progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Progress bar
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: AppColors.primary,
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Hint
                    Text(
                      'Double-tap to show subtitles',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
