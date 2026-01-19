import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart' as db;
import '../../../data/models/subtitle_entry.dart';
import '../widgets/subtitle_overlay.dart';
import '../widgets/word_popup.dart';

/// Video player screen with double-tap gesture for vocabulary
class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;

  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  
  db.Video? _videoData;
  List<SubtitleEntry> _subtitles = [];
  SubtitleEntry? _currentSubtitle;
  bool _showSubtitle = false;
  bool _isLoading = true;
  
  // Double tap detection
  DateTime? _lastTapTime;
  static const _doubleTapDelay = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    // Force landcape for better viewing? Or keep user preference.
    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _loadData();
  }

  Future<void> _loadData() async {
    final database = ref.read(databaseProvider);
    final video = await (database.select(database.videos)..where((t) => t.id.equals(widget.videoId))).getSingleOrNull();

    if (video != null) {
      if (mounted) {
        setState(() {
          _videoData = video;
        });
      }

      // Load subtitles from DB
      final dbSubs = await database.getSubtitlesForVideo(video.id);
      if (mounted) {
        setState(() {
          if (dbSubs.isNotEmpty) {
            _subtitles = dbSubs.map((s) => SubtitleEntry(
              index: s.subtitleIndex,
              startTime: Duration(milliseconds: s.startTimeMs),
              endTime: Duration(milliseconds: s.endTimeMs),
              text: s.content,
            )).toList();
          }
        });
      }

      // Initialize video player
      final file = File(video.filePath);
      if (await file.exists()) {
        _videoController = VideoPlayerController.file(file);
        await _videoController!.initialize();
        
        // Seek to last position
        if (video.lastPositionMs > 0) {
          await _videoController!.seekTo(Duration(milliseconds: video.lastPositionMs));
        }

        // Listen to position changes
        _videoController!.addListener(_onVideoPositionChanged);

        // Create Chewie controller
        if (mounted) {
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: false,
            showControls: true,
            allowedScreenSleep: false,
            allowFullScreen: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: AppColors.primary,
              handleColor: AppColors.primary,
              bufferedColor: Colors.white24,
              backgroundColor: Colors.white10,
            ),
            // Custom placeholder or UI could go here
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Video file not found on device')),
          );
        }
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onVideoPositionChanged() {
    if (_videoController == null || !_videoController!.value.isInitialized || !mounted) return;

    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;

    // Save progress periodically (throtled logic is good, keep distinct from UI)
    // We update subtitle logic even if hidden, so we have it ready for double-tap
    _updateCurrentSubtitle(position);

    // Save every ~5 sec
    if (position.inSeconds % 5 == 0 && _videoData != null) {
       ref.read(databaseProvider).updateVideoPosition(_videoData!.id, position.inMilliseconds);
    }

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
    
    // Always update state if it changed, so when we "Show", it's instant
    if (subtitle != _currentSubtitle) {
      if (mounted) {
        setState(() => _currentSubtitle = subtitle);
      }
    }
  }

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!) < _doubleTapDelay) {
      _handleDoubleTap();
      _lastTapTime = null;
    } else {
      _lastTapTime = now;
      // Let Chewie handle single tap (controls)
    }
  }

  void _handleDoubleTap() {
    if (_videoController == null) return;
    
    // Check if we have subtitles
    if (_subtitles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No subtitles available for this video'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Pause video and show subtitle
    _videoController!.pause();
    
    setState(() {
      _showSubtitle = true;
    });
    
    // Force find closest if current is null (e.g. paused in silence)
    if (_currentSubtitle == null) {
      final srtParser = ref.read(srtParserServiceProvider);
      _currentSubtitle = srtParser.findClosestToPosition(_subtitles, _videoController!.value.position);
      setState(() {});
    }
  }

  void _hideSubtitleAndResume() {
    setState(() {
      _showSubtitle = false;
    });
    _videoController?.play();
  }

  void _onWordTap(String word) async {
    final dictionaryService = ref.read(dictionaryServiceProvider);
    
    _videoController?.pause();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Glass effect managed by widget
      builder: (context) => WordPopup(
        word: word,
        contextSentence: _currentSubtitle?.text ?? '',
        timestamp: _videoController?.value.position ?? Duration.zero,
        videoId: widget.videoId,
        dictionaryService: dictionaryService,
        onClose: () => Navigator.pop(context),
        onSave: (vocabularyWord) async {
          final database = ref.read(databaseProvider);
          await database.upsertVocabularyWord(db.VocabularyWordsCompanion(
            id: drift.Value(vocabularyWord.id),
            word: drift.Value(vocabularyWord.word),
            partOfSpeech: drift.Value(vocabularyWord.partOfSpeech),
            definition: drift.Value(vocabularyWord.definition),
            example: drift.Value(vocabularyWord.example),
            phonetic: drift.Value(vocabularyWord.phonetic),
            audioUrl: drift.Value(vocabularyWord.audioUrl),
            videoId: drift.Value(vocabularyWord.videoId),
            videoTitle: drift.Value(_videoData?.title),
            timestampMs: drift.Value(vocabularyWord.timestamp.inMilliseconds),
            contextSentence: drift.Value(vocabularyWord.contextSentence),
            savedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
            easeFactor: drift.Value(2.5),
            intervalDays: drift.Value(1),
          ));

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Saved: ${vocabularyWord.word}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.success,
              ),
            );
          }

          _createLogicalClip(vocabularyWord.id, vocabularyWord.timestamp);
        },
      ),
    );
  }

  Future<void> _createLogicalClip(String wordId, Duration timestamp) async {
    if (_videoData == null) return;
    
    final database = ref.read(databaseProvider);
    final startTimeMs = max(0, timestamp.inMilliseconds - 5000);
    final endTimeMs = startTimeMs + 10000;

    await database.into(database.reviewClips).insert(db.ReviewClipsCompanion(
          id: drift.Value(const Uuid().v4()),
          vocabularyId: drift.Value(wordId),
          videoId: drift.Value(_videoData!.id),
          clipStartMs: drift.Value(startTimeMs),
          clipEndMs: drift.Value(endTimeMs),
          clipPath: const drift.Value(null), 
          createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  Future<void> _cleanExit() async {
    try {
      if (_videoController != null) {
        await _videoController!.pause();
      }
      _videoController?.removeListener(_onVideoPositionChanged);
      _chewieController?.dispose();
      await _videoController?.dispose();
      _chewieController = null;
      _videoController = null;
    } catch (e) {
      debugPrint('Error during player disposal: $e');
    }
  }

  @override
  void dispose() {
    _cleanExit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_chewieController == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(leading: const BackButton(color: Colors.white)),
        body: const Center(
          child: Text('Video failed to load', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          await _cleanExit();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Video Player
            Center(
              child: Chewie(controller: _chewieController!),
            ),
            
            // Gesture Layer
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 80, // Leave space for control bar if needed
              child: GestureDetector(
                onTap: _handleTap,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            
            // Subtitle Overlay
            if (_showSubtitle && _currentSubtitle != null)
              SubtitleOverlay(
                subtitle: _currentSubtitle!,
                onWordTap: _onWordTap,
                onDismiss: _hideSubtitleAndResume,
              ),

             // Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () {
                       // context.pop() will trigger PopScope which handles disposal
                       if (context.canPop()) {
                         context.pop();
                       } else {
                         // Fallback for direct launch or deep links
                         context.go('/home');
                       }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
