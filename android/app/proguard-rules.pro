# Flutter & Fundamental Plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Pigeon Generated Classes (Critical for Path Provider, etc)
-keep class dev.flutter.pigeon.** { *; }
-keep enum dev.flutter.pigeon.** { *; }
-keep interface dev.flutter.pigeon.** { *; }

# Media & Video
-keep class xyz.luan.games.play.play_games.** { *; }
-keep class video.api.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-keep class com.arthenica.ffmpegkit.** { *; }
-dontwarn com.arthenica.ffmpegkit.**

# Database (Drift / SQLite)
-keep class com.tekartik.sqflite.** { *; }
-keep class org.sqlite.database.** { *; }
-keep class net.sqlcipher.** { *; }
-keep class com.tekartik.sqlite3.** { *; }
-dontwarn net.sqlcipher.**

# Storage (Hive)
-keep class com.github.isvisoft.hive_flutter.** { *; }
-keep class io.hive.** { *; }

# General
-dontwarn io.flutter.embedding.**
-ignorewarnings

