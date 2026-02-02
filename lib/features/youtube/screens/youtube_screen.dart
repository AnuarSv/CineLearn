import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:collection';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class YouTubeScreen extends StatefulWidget {
  const YouTubeScreen({super.key});

  @override
  State<YouTubeScreen> createState() => _YouTubeScreenState();
}

class _YouTubeScreenState extends State<YouTubeScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  double _progress = 0;

  // uBlock-like script for YouTube (skips ads, hides overlays)
  static const String _adBlockScript = """
    (function() {
        const skipAds = () => {
            // Click "Skip Ad" buttons
            const skipButton = document.querySelector('.ytp-ad-skip-button, .ytp-ad-overlay-close-button');
            if (skipButton) {
                skipButton.click();
                console.log('YouTube Ad: Skipped via button click.');
            }

            // Fast-forward video ads
            const videoPlayer = document.querySelector('video');
            const adShowing = document.querySelector('.ad-showing');

            if (adShowing && videoPlayer) {
                if (!videoPlayer.ended && videoPlayer.duration > 0) {
                    videoPlayer.currentTime = videoPlayer.duration;
                    console.log('YouTube Ad: Fast-forwarded.');
                }
            }

            // Hide ad containers
            const adSelectors = [
                '#player-ads',
                'ytd-action-companion-ad-renderer',
                '.ytp-ad-overlay-slot',
                'ytd-promoted-sparkles-web-renderer',
                'ytd-display-ad-renderer',
                '#masthead-ad'
            ];
            
            adSelectors.forEach(selector => {
                const el = document.querySelector(selector);
                if (el && el.style.display !== 'none') {
                    el.style.display = 'none';
                }
            });
        };
        setInterval(skipAds, 500); // Check every 500ms
    })();
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri("https://m.youtube.com")),
              initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                iframeAllowFullscreen: true,
                userAgent: "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36",
                javaScriptEnabled: true,
                transparentBackground: true,
              ),
              initialUserScripts: UnmodifiableListView<UserScript>([
                UserScript(
                  source: _adBlockScript,
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                ),
              ]),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() => _isLoading = true);
              },
              onLoadStop: (controller, url) {
                setState(() => _isLoading = false);
              },
              onProgressChanged: (controller, progress) {
                setState(() => _progress = progress / 100);
              },
              shouldInterceptRequest: (controller, request) async {
                final url = request.url.toString();
                // Basic network filtering for known ad domains
                if (url.contains("doubleclick.net") || 
                    url.contains("googleadservices.com") || 
                    url.contains("googlesyndication.com")) {
                  return WebResourceResponse(); // Block
                }
                return null;
              },
            ),
            if (_isLoading || _progress < 1.0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  color: Colors.red,
                  minHeight: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
