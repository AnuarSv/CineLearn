import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../../app/theme/colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/video_processing_service.dart';
import '../../../data/database/app_database.dart';

/// Library screen for managing uploaded videos
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final videosAsync = ref.watch(videosStreamProvider);

    // Generate thumbnails for videos that don't have them
    videosAsync.whenData((videos) => _generateMissingThumbnails(videos));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Library',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(duration: 300.ms),
                        const SizedBox(height: 4),
                        videosAsync.when(
                          data: (videos) => Text(
                            '${videos.length} videos',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          loading: () => const SizedBox(height: 16),
                          error: (_, __) => const SizedBox(height: 16),
                        ).animate().fadeIn(delay: 100.ms),
                      ],
                    ),
                    _AddButton(
                      onTap: _pickVideo,
                      isLoading: _isImporting,
                    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
                  ],
                ),
              ),
            ),

            // Content
            videosAsync.when(
              data: (videos) {
                if (videos.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      onAddVideo: _pickVideo,
                      isDark: isDark,
                    ).animate().fadeIn(delay: 300.ms),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final video = videos[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                          child: _VideoCard(
                            video: video,
                            onTap: () => context.go('/player/${video.id}'),
                            onDelete: () => _deleteVideo(video),
                            isDark: isDark,
                          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)),
                        );
                      },
                      childCount: videos.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $error')),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    setState(() => _isImporting = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          final videoId = const Uuid().v4();
          final title = _extractTitle(file.name);
          
          // 1. Check for external subtitles first
          String? subtitlePath = await _findSubtitles(file.path!);

          // 2. If no external found, try to probe for embedded tracks
          if (subtitlePath == null) {
            final videoService = ref.read(videoProcessingServiceProvider);
            final tracks = await videoService.getSubtitleTracks(file.path!);
            
            if (tracks.isNotEmpty && mounted) {
              final selectedTrack = await _showTrackSelectionDialog(tracks);
              if (selectedTrack != null) {
                subtitlePath = await videoService.extractSubtitleTrack(file.path!, selectedTrack.index);
              }
            }
          }

          final db = ref.read(databaseProvider);
          final videoService = ref.read(videoProcessingServiceProvider);
          
          // Generate thumbnail
          final thumbnailPath = await videoService.generateThumbnail(file.path!);

          await db.upsertVideo(VideosCompanion(
            id: drift.Value(videoId),
            title: drift.Value(title),
            filePath: drift.Value(file.path!),
            subtitlePath: drift.Value(subtitlePath),
            thumbnailPath: drift.Value(thumbnailPath),
            addedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
            durationMs: const drift.Value(0),
          ));

          // If subtitle found (external or newly extracted), parse and store
          if (subtitlePath != null) {
            await _importSubtitles(videoId, subtitlePath);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Imported: $title (with subtitles)'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } else {
            if (mounted) {
              await _showNoSubtitlesWarning(file.name);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<SubtitleTrack?> _showTrackSelectionDialog(List<SubtitleTrack> tracks) async {
    return showDialog<SubtitleTrack>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Subtitle Track'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                leading: const Icon(Icons.subtitles_rounded),
                title: Text(track.title ?? 'Track ${track.index}'),
                subtitle: track.language != null ? Text(track.language!) : null,
                onTap: () => Navigator.pop(context, track),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNoSubtitlesWarning(String fileName) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Subtitles Found'),
        content: Text(
          'To use learning features, please ensure an .srt file exists in the same folder as "$fileName", or that the video contains internal subtitle tracks.\n\n'
          'Example:\nMovie.mp4\nMovie.srt',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String?> _findSubtitles(String videoPath) async {
    final videoFile = File(videoPath);
    final dir = videoFile.parent;
    final baseName = videoPath.split('/').last.replaceAll(RegExp(r'\.[^.]+$'), '');
    
    // Patterns to look for, in order of preference
    final patterns = [
      '$baseName.srt',
      '$baseName.en.srt',
      '$baseName.eng.srt',
      '${baseName}_en.srt',
      '${baseName}_eng.srt',
    ];

    try {
      final files = dir.listSync();
      for (final pattern in patterns) {
        // Case-insensitive check
        final match = files.firstWhere(
          (f) => f.path.split('/').last.toLowerCase() == pattern.toLowerCase(),
          orElse: () => File(''),
        );
        if (match.path.isNotEmpty) {
          return match.path;
        }
      }
    } catch (e) {
      debugPrint('Error searching for subtitles: $e');
    }
    return null;
  }

  Future<void> _importSubtitles(String videoId, String path) async {
    final srtParser = ref.read(srtParserServiceProvider);
    final db = ref.read(databaseProvider);

    try {
      final content = await File(path).readAsString();
      final entries = srtParser.parse(content);
      
      final companions = entries.map((e) => SubtitlesCompanion(
        videoId: drift.Value(videoId),
        subtitleIndex: drift.Value(e.index),
        startTimeMs: drift.Value(e.startTime.inMilliseconds),
        endTimeMs: drift.Value(e.endTime.inMilliseconds),
        content: drift.Value(e.text),
      )).toList();

      await db.insertSubtitles(videoId, companions);
    } catch (e) {
      debugPrint('Error importing subtitles: $e');
    }
  }

  String _extractTitle(String filename) {
    return filename
        .replaceAll(RegExp(r'\.[^.]+$'), '')
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .trim();
  }

  void _deleteVideo(Video video) async {
    final db = ref.read(databaseProvider);
    await db.deleteVideo(video.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted: ${video.title}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _generateMissingThumbnails(List<Video> videos) {
    final videoService = ref.read(videoProcessingServiceProvider);
    final db = ref.read(databaseProvider);
    
    for (final video in videos) {
      if (video.thumbnailPath == null || !File(video.thumbnailPath!).existsSync()) {
        videoService.generateThumbnail(video.filePath).then((path) {
          if (path != null) {
            db.upsertVideo(VideosCompanion(
              id: drift.Value(video.id),
              thumbnailPath: drift.Value(path),
            ));
          }
        });
      }
    }
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _AddButton({required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddVideo;
  final bool isDark;

  const _EmptyState({required this.onAddVideo, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.video_library_outlined,
                size: 64,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'No videos in library',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Add a movie or series with English subtitles\nto start learning vocabulary',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton.icon(
              onPressed: onAddVideo,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Video'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isDark;

  const _VideoCard({
    required this.video,
    required this.onTap,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = video.durationMs > 0 ? video.lastPositionMs / video.durationMs : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: Row(
          children: [
            // Thumbnail placeholder
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppTheme.radiusMedium),
                ),
                image: video.thumbnailPath != null && File(video.thumbnailPath!).existsSync()
                    ? DecorationImage(
                        image: FileImage(File(video.thumbnailPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (video.thumbnailPath == null || !File(video.thumbnailPath!).existsSync())
                    Icon(
                      Icons.movie_outlined,
                      size: 32,
                      color: AppColors.textTertiary,
                    ),
                  if (progress > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.black12,
                        color: AppColors.accent,
                        minHeight: 3,
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (video.subtitlePath != null) ...[
                          Icon(
                            Icons.subtitles_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Subtitles',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Options button
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              color: AppColors.textTertiary,
              onPressed: () => _showOptions(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: const Text('Play'),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
