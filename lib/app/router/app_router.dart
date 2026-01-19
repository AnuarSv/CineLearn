import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/library/screens/library_screen.dart';
import '../../features/vocabulary/screens/vocabulary_list_screen.dart';
import '../../features/vocabulary/screens/flashcard_screen.dart';
import '../../features/reels/screens/reels_screen.dart';
import '../../features/games/screens/games_hub_screen.dart';
import '../../features/player/screens/video_player_screen.dart';
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
          return MaterialPage(
            fullscreenDialog: true,
            child: VideoPlayerScreen(videoId: videoId),
          );
        },
      ),
      GoRoute(
        path: '/flashcards',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: FlashcardScreen(),
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
}
