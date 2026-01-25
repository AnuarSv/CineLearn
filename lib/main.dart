import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/providers.dart';
import 'app/app.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Hive for local settings
    await Hive.initFlutter();
    
    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const CineLearnApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('FATAL ERROR DURING INIT: $e');
    debugPrint(stackTrace.toString());
    // Still try to run the app to show something if possible, or at least it won't be a silent hang
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SelectableText('Initialization Error: $e\n\n$stackTrace'),
          ),
        ),
      )
    );
  }
}
