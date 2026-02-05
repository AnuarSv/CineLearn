import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/youtube_extractor_service.dart';
import '../../../app/theme/colors.dart';

class YouTubeScreen extends StatefulWidget {
  const YouTubeScreen({super.key});

  @override
  State<YouTubeScreen> createState() => _YouTubeScreenState();
}

class _YouTubeScreenState extends State<YouTubeScreen> {
  InAppWebViewController? _webViewController;
  String? _sniffedSubtitleUrl;
  String? _currentVideoId;
  bool _canOpen = false;

  void _onUrlChanged(WebUri? url) {
    if (url == null) return;
    final videoId = _extractVideoId(url.toString());
    if (videoId != _currentVideoId) {
      setState(() {
        _currentVideoId = videoId;
        _sniffedSubtitleUrl = null; // Сбрасываем старую ссылку
        _canOpen = videoId != null;
      });
    }
  }

  String? _extractVideoId(String url) {
    if (url.contains('v=')) return url.split('v=')[1].split('&')[0];
    if (url.contains('youtu.be/')) return url.split('youtu.be/')[1].split('?')[0];
    if (url.contains('shorts/')) return url.split('shorts/')[1].split('?')[0];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Browser'),
        backgroundColor: AppColors.darkSurface,
        actions: [
          if (_canOpen)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Передаем ID видео и (если поймали) прямую ссылку на сабы
                  final encodedSubs = _sniffedSubtitleUrl != null 
                      ? Uri.encodeComponent(_sniffedSubtitleUrl!) 
                      : '';
                  context.push('/player/${_currentVideoId!}?type=youtube&subsUrl=$encodedSubs');
                },
                icon: const Icon(Icons.play_circle_fill),
                label: Text(_sniffedSubtitleUrl != null ? 'Open with Subs' : 'Open in Player'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sniffedSubtitleUrl != null ? Colors.green : AppColors.accent,
                ),
              ),
            ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri("https://m.youtube.com")),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          userAgent: "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36",
        ),
        onWebViewCreated: (controller) => _webViewController = controller,
        onLoadStop: (controller, url) => _onUrlChanged(url),
        onUpdateVisitedHistory: (controller, url, isReload) => _onUrlChanged(url),
        
        // СТРАТЕГИЯ СНИФФЕРА: перехватываем запросы к субтитрам
        onLoadResource: (controller, resource) {
          final url = resource.url.toString();
          if (url.contains('api/timedtext') && url.contains('lang=en')) {
            print('SNIFFED SUBTITLES: $url');
            if (mounted) {
              setState(() {
                _sniffedSubtitleUrl = url;
              });
            }
          }
        },
      ),
    );
  }
}