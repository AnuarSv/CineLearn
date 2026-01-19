import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart' as db;

/// Reels screen: vertical video feed for reviewing vocabulary
class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final PageController _pageController = PageController();
  List<db.ReviewClip> _clips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClips();
  }

  Future<void> _loadClips() async {
    final database = ref.read(databaseProvider);
    final clips = await database.select(database.reviewClips).get();
    
    if (mounted) {
      setState(() {
        _clips = clips..shuffle();
        _isLoading = false;
      });
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
        title: Text('Reels Review', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _clips.length,
        itemBuilder: (context, index) {
          return _ReelItem(
            clip: _clips[index],
            isActive: true,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _ReelItem extends ConsumerStatefulWidget {
  final db.ReviewClip clip;
  final bool isActive;

  const _ReelItem({required this.clip, required this.isActive});

  @override
  ConsumerState<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends ConsumerState<_ReelItem> {
  VideoPlayerController? _videoController;
  db.VocabularyWord? _word;
  bool _showQuiz = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final database = ref.read(databaseProvider);
    
    _word = await (database.select(database.vocabularyWords)..where((t) => t.id.equals(widget.clip.vocabularyId))).getSingleOrNull();

    // Determine Video Source
    String? sourcePath = widget.clip.clipPath;
    
    // If logical clip (path is null), find parent video
    if (sourcePath == null) {
      final parentVideo = await (database.select(database.videos)..where((t) => t.id.equals(widget.clip.videoId))).getSingleOrNull();
      sourcePath = parentVideo?.filePath;
    }

    if (sourcePath != null && File(sourcePath).existsSync()) {
      _videoController = VideoPlayerController.file(File(sourcePath));
      await _videoController!.initialize();
      await _videoController!.seekTo(Duration(milliseconds: widget.clip.clipStartMs));
      await _videoController!.play();
      _videoController!.addListener(_loopListener);
      
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  void _loopListener() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    
    final positionMs = _videoController!.value.position.inMilliseconds;
    if (positionMs >= widget.clip.clipEndMs) {
      _videoController!.seekTo(Duration(milliseconds: widget.clip.clipStartMs));
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_loopListener);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _videoController == null) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
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
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),

        // Content
        if (_word != null)
          Positioned(
            left: 20,
            bottom: 40,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _word!.word,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                  ),
                ).animate().fadeIn().slideX(),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (_word!.partOfSpeech ?? 'noun').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ), 
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  _word!.definition ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),

        // Action buttons
        Positioned(
          right: 10,
          bottom: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.bookmark_added_rounded,
                label: 'Saved',
                color: AppColors.success,
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.quiz_outlined,
                label: 'Quiz',
                onTap: () => setState(() => _showQuiz = !_showQuiz),
              ),
            ],
          ),
        ),

        // Quiz overlay
        if (_showQuiz)
          Positioned.fill(
            child: _QuizOverlay(
              word: _word?.word ?? '',
              onClose: () => setState(() => _showQuiz = false),
            ),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: color ?? Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 12, 
              fontWeight: FontWeight.w500,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizOverlay extends StatelessWidget {
  final String word;
  final VoidCallback onClose;

  const _QuizOverlay({required this.word, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'What did you hear?',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          _QuizOption(label: word, isCorrect: true, onTap: onClose),
          const SizedBox(height: 16),
          _QuizOption(label: 'Alternative Answer', isCorrect: false, onTap: onClose),
        ],
      ).animate().fadeIn(),
    );
  }
}

class _QuizOption extends StatelessWidget {
  final String label;
  final bool isCorrect;
  final VoidCallback onTap;

  const _QuizOption({
    required this.label,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white.withOpacity(0.05),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.movie_filter_rounded, color: AppColors.primary, size: 80)
                  .animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
              const SizedBox(height: 32),
              const Text(
                'Your Reels are Empty',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Watch a movie and save words to generate your personalized learning feed.',
                style: TextStyle(color: Colors.white54, fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
