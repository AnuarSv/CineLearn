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
import '../../../data/models/vocabulary_word.dart' as model;
import '../../../core/services/youtube_extractor_service.dart';
import '../widgets/subtitle_overlay.dart';
import '../widgets/word_popup.dart';
import '../../../app/widgets/glass_container.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  final String type; // 'local' or 'youtube'
  final String? subsUrl;

  const VideoPlayerScreen({
    super.key, 
    required this.videoId, 
    this.type = 'local',
    this.subsUrl,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  
  String? _videoTitle;
  List<SubtitleEntry> _subtitles = [];
  SubtitleEntry? _currentSubtitle;
  
  bool _isLoading = true;
  bool _showControls = true;
  bool _showSubtitleOverlay = false;
  
  DateTime? _lastInteraction;
  static const _controlsHideDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller?.removeListener(_onVideoPositionChanged);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.type == 'youtube') {
      await _loadYouTubeData();
    } else {
      await _loadLocalData();
    }
  }

  Future<void> _loadYouTubeData() async {
    try {
      final extractor = YouTubeExtractorService();
      final data = await extractor.extractData(widget.videoId, manualSubsUrl: widget.subsUrl);
      
      if (!mounted) return;

      setState(() {
        _videoTitle = data.title;
        _subtitles = _processSubtitles(data.subtitles);
      });

      if (mounted) {
        final count = _subtitles.length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(count > 0 ? 'Loaded $count English subtitles' : 'NO ENGLISH SUBTITLES FOUND'),
            duration: const Duration(seconds: 2),
            backgroundColor: count > 0 ? AppColors.success : AppColors.error,
          ),
        );
      }

      _controller = VideoPlayerController.networkUrl(Uri.parse(data.videoUrl));
      await _controller!.initialize();
      
      _controller!.addListener(_onVideoPositionChanged);
      _controller!.play();

      setState(() => _isLoading = false);
      _startControlsTimer();
      extractor.dispose();
    } catch (e) {
      debugPrint('YouTube Load Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load YouTube video: $e')),
        );
        context.go('/home');
      }
    }
  }

  Future<void> _loadLocalData() async {
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

    setState(() => _videoTitle = video.title);

    final dbSubs = await database.getSubtitlesForVideo(video.id);
    if (mounted && dbSubs.isNotEmpty) {
      final rawSubs = dbSubs.map((s) => SubtitleEntry(
        index: s.subtitleIndex,
        startTime: Duration(milliseconds: s.startTimeMs),
        endTime: Duration(milliseconds: s.endTimeMs),
        text: s.content,
      )).toList();
      
      setState(() {
        _subtitles = _processSubtitles(rawSubs);
      });
    }

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

  /// Растягиваем субтитры, чтобы закрыть маленькие дыры (до 3 сек)
  List<SubtitleEntry> _processSubtitles(List<SubtitleEntry> subs) {
    if (subs.isEmpty) return [];
    
    final List<SubtitleEntry> processed = [];
    for (int i = 0; i < subs.length; i++) {
      var current = subs[i];
      if (i < subs.length - 1) {
        final next = subs[i + 1];
        final gap = next.startTime.inMilliseconds - current.endTime.inMilliseconds;
        
        // Если пауза между фразами меньше 3 секунд, растягиваем текущую фразу
        if (gap > 0 && gap < 3000) {
          current = current.copyWith(
            endTime: next.startTime - const Duration(milliseconds: 100),
          );
        }
      }
      processed.add(current);
    }
    return processed;
  }

  void _onVideoPositionChanged() {
    if (_controller == null || !_controller!.value.isInitialized || !mounted) return;

    final position = _controller!.value.position;
    _updateCurrentSubtitle(position);

    // Только для локальных видео сохраняем прогресс в БД
    if (widget.type == 'local' && position.inSeconds % 10 == 0) {
      ref.read(databaseProvider).updateVideoPosition(widget.videoId, position.inMilliseconds);
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
    
    // Ищем текущий субтитр. Если нет - ищем ближайший в пределах 5 секунд назад
    if (_currentSubtitle == null) {
      final srtParser = ref.read(srtParserServiceProvider);
      _currentSubtitle = srtParser.findClosestToPosition(
        _subtitles, 
        _controller!.value.position,
      );
    }
    
    // Если всё равно пусто - берем самый последний из списка, который был
    if (_currentSubtitle == null && _subtitles.isNotEmpty) {
       _currentSubtitle = _subtitles.lastWhere(
         (s) => s.endTime <= _controller!.value.position,
         orElse: () => _subtitles.first,
       );
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

  void _onWordTapped(String word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WordPopup(
        word: word,
        contextSentence: _currentSubtitle?.text ?? '',
        timestamp: _controller!.value.position,
        videoId: widget.videoId,
        cacheService: ref.read(dictionaryCacheServiceProvider),
        onClose: () => Navigator.pop(context),
        onSave: (wordObj) => _onSaveWord(wordObj),
      ),
    );
  }

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
        videoTitle: drift.Value(_videoTitle ?? wordObj.videoTitle),
        timestampMs: drift.Value(wordObj.timestamp.inMilliseconds),
        contextSentence: drift.Value(wordObj.contextSentence),
        savedAt: drift.Value(wordObj.savedAt.millisecondsSinceEpoch),
      );

      await database.upsertVocabularyWord(entry);

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
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
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
                        Container(
                          color: Colors.black,
                          child: Center(
                            child: _controller!.value.isInitialized && _controller!.value.aspectRatio > 0
                                ? AspectRatio(
                                    aspectRatio: _controller!.value.aspectRatio,
                                    child: VideoPlayer(_controller!),
                                  )
                                : const CircularProgressIndicator(color: Colors.white24),
                          ),
                        ),
                        if (!_showSubtitleOverlay)
                          IgnorePointer(
                            ignoring: !_showControls,
                            child: _buildControlsOverlay(),
                          ),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _videoTitle ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
              ),
            ),
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
                    Slider(
                      value: position.inMilliseconds.toDouble(),
                      min: 0,
                      max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                      onChanged: (value) {
                        _controller!.seekTo(Duration(milliseconds: value.toInt()));
                        _lastInteraction = DateTime.now();
                      },
                      activeColor: AppColors.success,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position), style: const TextStyle(color: Colors.white)),
                        Text(_formatDuration(duration), style: const TextStyle(color: Colors.white)),
                      ],
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
}