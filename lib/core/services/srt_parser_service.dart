import '../../data/models/subtitle_entry.dart';

/// Helper class to hold timestamp range
class TimestampRange {
  final Duration start;
  final Duration end;
  
  TimestampRange(this.start, this.end);
}

/// Service for parsing SRT subtitle files
class SrtParserService {
  /// Parse SRT file content into list of SubtitleEntry
  List<SubtitleEntry> parse(String content) {
    final List<SubtitleEntry> entries = [];
    
    // Normalize line endings
    final normalizedContent = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    
    // Split into blocks (separated by empty lines)
    final blocks = normalizedContent.split(RegExp(r'\n\n+'));
    
    for (final block in blocks) {
      final entry = _parseBlock(block.trim());
      if (entry != null) {
        entries.add(entry);
      }
    }
    
    return entries;
  }

  /// Parse a single SRT block
  SubtitleEntry? _parseBlock(String block) {
    if (block.isEmpty) return null;
    
    final lines = block.split('\n');
    if (lines.length < 3) return null;
    
    try {
      // First line: index number
      final index = int.tryParse(lines[0].trim());
      if (index == null) return null;
      
      // Second line: timestamp range
      final timestampLine = lines[1].trim();
      final timestamps = _parseTimestamps(timestampLine);
      if (timestamps == null) return null;
      
      // Remaining lines: subtitle text
      final textLines = lines.sublist(2);
      final text = textLines
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .join(' ');
      
      if (text.isEmpty) return null;
      
      return SubtitleEntry(
        index: index,
        startTime: timestamps.start,
        endTime: timestamps.end,
        text: _cleanText(text),
      );
    } catch (e) {
      // Skip malformed blocks
      return null;
    }
  }

  /// Parse timestamp line: "00:01:23,456 --> 00:01:25,789"
  TimestampRange? _parseTimestamps(String line) {
    final separatorIndex = line.indexOf('-->');
    if (separatorIndex == -1) return null;
    
    final startStr = line.substring(0, separatorIndex).trim();
    final endStr = line.substring(separatorIndex + 3).trim();
    
    final startTime = _parseTimestamp(startStr);
    final endTime = _parseTimestamp(endStr);
    
    if (startTime == null || endTime == null) return null;
    
    return TimestampRange(startTime, endTime);
  }

  /// Parse single timestamp: "00:01:23,456" or "00:01:23.456"
  Duration? _parseTimestamp(String timestamp) {
    // Handle both comma and dot as millisecond separator
    final normalized = timestamp.replaceAll(',', '.');
    
    // Match HH:MM:SS.mmm or HH:MM:SS
    final regex = RegExp(r'^(\d{1,2}):(\d{2}):(\d{2})(?:\.(\d{1,3}))?$');
    final match = regex.firstMatch(normalized);
    
    if (match == null) return null;
    
    try {
      final hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      final seconds = int.parse(match.group(3)!);
      final milliseconds = match.group(4) != null
          ? int.parse(match.group(4)!.padRight(3, '0'))
          : 0;
      
      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    } catch (e) {
      return null;
    }
  }

  /// Clean subtitle text from formatting tags
  String _cleanText(String text) {
    return text
        // Remove HTML/formatting tags
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Remove curly brace formatting (ASS style)
        .replaceAll(RegExp(r'\{[^}]*\}'), '')
        // Normalize whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Find subtitle entry at a specific position
  SubtitleEntry? findAtPosition(List<SubtitleEntry> entries, Duration position) {
    for (final entry in entries) {
      if (entry.containsPosition(position)) {
        return entry;
      }
    }
    return null;
  }

  /// Find subtitle entry closest to a position
  SubtitleEntry? findClosestToPosition(List<SubtitleEntry> entries, Duration position) {
    if (entries.isEmpty) return null;
    
    SubtitleEntry? closest;
    Duration minDistance = const Duration(days: 365);
    
    for (final entry in entries) {
      // Check if position is within the entry
      if (entry.containsPosition(position)) {
        return entry;
      }
      
      // Calculate distance to entry
      final distanceToStart = _absDuration(entry.startTime - position);
      final distanceToEnd = _absDuration(entry.endTime - position);
      final minDist = distanceToStart < distanceToEnd ? distanceToStart : distanceToEnd;
      
      if (minDist < minDistance) {
        minDistance = minDist;
        closest = entry;
      }
    }
    
    // Return closest only if within 3 seconds
    if (minDistance <= const Duration(seconds: 3)) {
      return closest;
    }
    
    return null;
  }

  Duration _absDuration(Duration duration) {
    return duration.isNegative ? -duration : duration;
  }

  /// Get previous subtitle entry
  SubtitleEntry? getPrevious(List<SubtitleEntry> entries, Duration position) {
    SubtitleEntry? previous;
    
    for (final entry in entries) {
      if (entry.endTime <= position) {
        previous = entry;
      } else {
        break;
      }
    }
    
    return previous;
  }

  /// Get next subtitle entry
  SubtitleEntry? getNext(List<SubtitleEntry> entries, Duration position) {
    for (final entry in entries) {
      if (entry.startTime > position) {
        return entry;
      }
    }
    return null;
  }
}
