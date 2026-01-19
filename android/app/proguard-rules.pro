# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Media & Video
-keep class xyz.luan.games.play.play_games.** { *; }
-keep class video.api.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Drift / SQLite
-keep class com.tekartik.sqflite.** { *; }
-keep class org.sqlite.database.** { *; }

# General Flutter
-dontwarn io.flutter.embedding.**
-ignorewarnings

# FFmpeg
-keep class com.arthenica.ffmpegkit.** { *; }
-dontwarn com.arthenica.ffmpegkit.**

# Path Provider (Pigeon)
-keep class dev.flutter.pigeon.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }

