import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/theme/colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart' as db;

/// Optimized Reels screen with lazy video loading
class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final PageController _pageController = PageController();
  List<db.ReviewClip> _clips = [];
  bool _isLoading = true;
  int _currentPage = 0;

  // Cache of video controllers - only keep current + next + previous
  final Map<int, _ReelController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadClips();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage) {
      setState(() => _currentPage = newPage);
      _manageControllers();
    }
  }

  void _manageControllers() {
    // Keep only current, prev, and next
    final toKeep = {_currentPage - 1, _currentPage, _currentPage + 1};
    
    // Dispose controllers outside the window
    _controllers.removeWhere((index, controller) {
      if (!toKeep.contains(index)) {
        controller.dispose();
        return true;
      }
      return false;
    });

    // Pre-initialize next 2 controllers for smoothness
    for (int i = 1; i <= 2; i++) {
      final nextIndex = _currentPage + i;
      if (nextIndex < _clips.length && !_controllers.containsKey(nextIndex)) {
        _initControllerAt(nextIndex);
      }
    }
  }

  Future<void> _initControllerAt(int index) async {
    if (index < 0 || index >= _clips.length) return;
    if (_controllers.containsKey(index)) return;

    final database = ref.read(databaseProvider);
    final clip = _clips[index];
    
    final word = await (database.select(database.vocabularyWords)
          ..where((t) => t.id.equals(clip.vocabularyId)))
        .getSingleOrNull();

    String? sourcePath = clip.clipPath;
    if (sourcePath == null) {
      final parentVideo = await (database.select(database.videos)
            ..where((t) => t.id.equals(clip.videoId)))
          .getSingleOrNull();
      sourcePath = parentVideo?.filePath;
    }

    if (sourcePath != null && File(sourcePath).existsSync()) {
      final controller = _ReelController(
        clip: clip,
        word: word,
        sourcePath: sourcePath,
      );
      await controller.initialize();
      
      if (mounted) {
        setState(() => _controllers[index] = controller);
      }
    }
  }

  Future<void> _loadClips() async {
    final database = ref.read(databaseProvider);
    final clips = await database.select(database.reviewClips).get();

    if (mounted) {
      setState(() {
        _clips = clips..shuffle();
        _isLoading = false;
      });
      
      // Initialize first two controllers (async, don't await to show UI fast)
      if (_clips.isNotEmpty) {
        _initControllerAt(0);
        if (_clips.length > 1) {
          _initControllerAt(1);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_clips.isEmpty) {
      return _EmptyState();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Reels Review', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _clips.length,
        onPageChanged: (index) {
          // Pause all other controllers, play current
          _controllers.forEach((i, c) {
            if (i == index) {
              c.play();
            } else {
              c.pause();
            }
          });
        },
        itemBuilder: (context, index) {
          final controller = _controllers[index];
          if (controller == null || !controller.isInitialized) {
            return _LoadingPlaceholder();
          }
          return _ReelItem(controller: controller);
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// Wraps video controller and associated data
class _ReelController {
  final db.ReviewClip clip;
  final db.VocabularyWord? word;
  final String sourcePath;
  VideoPlayerController? _videoController;
  bool isInitialized = false;

  _ReelController({
    required this.clip,
    required this.word,
    required this.sourcePath,
  });

  VideoPlayerController? get videoController => _videoController;

  bool get _isUsingPhysicalClip => clip.clipPath != null && sourcePath == clip.clipPath;

  Future<void> initialize() async {
    _videoController = VideoPlayerController.file(File(sourcePath));
    await _videoController!.initialize();
    
    final startAt = _isUsingPhysicalClip ? 0 : clip.clipStartMs;
    await _videoController!.seekTo(Duration(milliseconds: startAt));
    
    await _videoController!.setLooping(false);
    _videoController!.addListener(_loopListener);
    isInitialized = true;
  }

  void _loopListener() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    
    final positionMs = _videoController!.value.position.inMilliseconds;
    final startAt = _isUsingPhysicalClip ? 0 : clip.clipStartMs;
    final endAt = _isUsingPhysicalClip 
        ? _videoController!.value.duration.inMilliseconds 
        : clip.clipEndMs;

    if (positionMs >= endAt) {
      _videoController!.seekTo(Duration(milliseconds: startAt));
    }
  }

  void play() {
    _videoController?.play();
  }

  void pause() {
    _videoController?.pause();
  }

  void dispose() {
    _videoController?.removeListener(_loopListener);
    _videoController?.dispose();
  }
}

class _ReelItem extends ConsumerWidget {
  final _ReelController controller;

  const _ReelItem({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final word = controller.word;
    final videoController = controller.videoController;

    if (videoController == null) {
      return _LoadingPlaceholder();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video
        GestureDetector(
          onTap: () {
            if (videoController.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          },
          child: Center(
            child: AspectRatio(
              aspectRatio: videoController.value.aspectRatio,
              child: VideoPlayer(videoController),
            ),
          ),
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Word info
        if (word != null)
          Positioned(
            left: 20,
            bottom: 100,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                  ),
                ).animate().fadeIn().slideX(begin: -0.1),

                const SizedBox(height: 8),

                if (word.partOfSpeech != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      word.partOfSpeech!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 16),

                Text(
                  word.definition ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),

        // Side Actions
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              _ReelActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {
                  final currentWord = word;
                  if (currentWord != null) {
                    final shareService = ref.read(shareServiceProvider);
                    shareService.shareReelCard(
                      currentWord.word,
                      currentWord.definition ?? 'No definition',
                      controller.clip.clipPath ?? '',
                    );
                  }
                },
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2),
              
              const SizedBox(height: 20),
              
              _ReelActionButton(
                icon: Icons.favorite_border_rounded,
                label: 'Like',
                onTap: () {}, // TODO: Implement favorites
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
            ],
          ),
        ),

        // Progress bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: videoController,
            builder: (context, value, child) {
              final clipDuration = controller.clip.clipEndMs - controller.clip.clipStartMs;
              final progress = (value.position.inMilliseconds - controller.clip.clipStartMs) / clipDuration;
              return LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white24,
                color: AppColors.primary,
                minHeight: 3,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade900,
        highlightColor: Colors.grey.shade700,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.movie_filter_rounded,
                  color: AppColors.primary,
                  size: 50,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),
              
              const SizedBox(height: 32),
              
              const Text(
                'No Reels Yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Watch a movie and save words to generate your personalized learning feed.',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReelActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ReelActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.glassBackgroundStrong,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
}
