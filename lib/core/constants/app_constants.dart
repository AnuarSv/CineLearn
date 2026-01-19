/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'CineLearn';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'cinelearn.db';
  static const int databaseVersion = 1;
  
  // Video
  static const List<String> supportedVideoFormats = ['mp4', 'mkv', 'avi', 'mov', 'webm'];
  static const List<String> supportedSubtitleFormats = ['srt', 'vtt'];
  
  // Vocabulary
  static const int freeWordsPerDay = 5;
  static const int maxRecentWords = 50;
  
  // Reels
  static const int clipDurationSeconds = 8; // Duration of video clips for reels
  static const int clipPaddingSeconds = 2; // Extra seconds before/after the word
  
  // Spaced Repetition (SM-2 Algorithm)
  static const double initialEaseFactor = 2.5;
  static const double minEaseFactor = 1.3;
  static const List<int> initialIntervals = [1, 6]; // days
  
  // UI
  static const int maxSubtitleLines = 2;
  static const double subtitleFontSizeMin = 14.0;
  static const double subtitleFontSizeMax = 24.0;
  static const double subtitleFontSizeDefault = 18.0;
  
  // Animation durations (milliseconds)
  static const int animationFast = 150;
  static const int animationNormal = 300;
  static const int animationSlow = 500;
  
  // Gesture
  static const int doubleTapTimeout = 300; // ms to detect double tap
  
  // Storage keys
  static const String keyThemeMode = 'theme_mode';
  static const String keySubtitleSize = 'subtitle_size';
  static const String keyLastVideoPath = 'last_video_path';
  static const String keyOnboardingComplete = 'onboarding_complete';
}
