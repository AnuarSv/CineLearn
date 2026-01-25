import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Main CineLearn application widget
class CineLearnApp extends ConsumerWidget {
  const CineLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final ThemeMode themeMode = userPrefs.isAutoTheme 
        ? ThemeMode.system 
        : (userPrefs.isDarkMode ? ThemeMode.dark : ThemeMode.light);

    return MaterialApp.router(
      title: 'CineLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
