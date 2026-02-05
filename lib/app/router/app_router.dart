import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/subscription/screens/subscription_screen.dart';
import '../../features/library/screens/library_screen.dart';
import '../../features/vocabulary/screens/vocabulary_list_screen.dart';
import '../../features/vocabulary/screens/flashcard_screen.dart';
import '../../features/reels/screens/reels_screen.dart';
import '../../features/games/screens/games_hub_screen.dart';
import '../../features/player/screens/video_player_screen.dart';
import '../../features/games/screens/listening_quiz_screen.dart';
import '../../features/games/screens/word_puzzle_screen.dart';
import '../../features/games/screens/fill_blank_screen.dart';
import '../../features/games/screens/match_game_screen.dart';
import '../../features/youtube/screens/youtube_screen.dart';
import '../shell/app_shell.dart';

/// App router configuration using GoRouter
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LibraryScreen(),
            ),
          ),
          GoRoute(
            path: '/reels',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReelsScreen(),
            ),
          ),
          GoRoute(
            path: '/vocabulary',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VocabularyListScreen(),
            ),
          ),
          GoRoute(
            path: '/games',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GamesHubScreen(),
            ),
          ),
        ],
      ),
      // Full screen routes (outside shell)
      GoRoute(
        path: '/player/:videoId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final videoId = state.pathParameters['videoId']!;
          final type = state.uri.queryParameters['type'] ?? 'local';
          final subsUrl = state.uri.queryParameters['subsUrl'];
          return MaterialPage(
            fullscreenDialog: true,
            child: VideoPlayerScreen(videoId: videoId, type: type, subsUrl: subsUrl),
          );
        },
      ),
      GoRoute(
        path: '/flashcards',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: FlashcardScreen(),
        ),
      ),
      // Game Routes
      GoRoute(
        path: '/games/listening',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: ListeningQuizScreen(),
        ),
      ),
      GoRoute(
        path: '/games/puzzle',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: WordPuzzleScreen(),
        ),
      ),
      GoRoute(
        path: '/games/fill',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: FillBlankScreen(),
        ),
      ),
      GoRoute(
        path: '/games/match',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: MatchGameScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/subscription',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: SubscriptionScreen(),
        ),
      ),
      GoRoute(
        path: '/youtube',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: YouTubeScreen(),
        ),
      ),
    ],
  );
}

/// Route paths for navigation
class AppRoutes {
  static const home = '/home';
  static const library = '/library';
  static const reels = '/reels';
  static const vocabulary = '/vocabulary';
  static const games = '/games';
  static String player(String videoId) => '/player/$videoId';
  static const flashcards = '/flashcards';
  static const listeningQuiz = '/games/listening';
  static const wordPuzzle = '/games/puzzle';
  static const fillBlank = '/games/fill';
  static const matchGame = '/games/match';
}
