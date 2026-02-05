import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const videoId = 'jNQXAC9IVRw'; // "Me at the zoo" - классика для теста
  final logFile = File('subs_test_results.txt');
  final sink = logFile.openWrite();

  void log(String msg) {
    print(msg);
    sink.writeln(msg);
  }

  log('=== YOUTUBE SUBTITLE LAB TEST 2026 ===');
  log('Video ID: $videoId');

  // МЕТОД 1: InnerTube Android Client (Самый мощный)
  log('\n--- Method 1: InnerTube Android Client ---');
  try {
    final payload = {
      "videoId": videoId,
      "context": {
        "client": {
          "clientName": "ANDROID",
          "clientVersion": "19.05.35",
          "hl": "en",
          "gl": "US"
        }
      }
    };
    final res = await http.post(
      Uri.parse('https://www.youtube.com/youtubei/v1/player?key=AIzaSyAO_FJ2Sl_Anp3_SAtI8m_n6Eq_d0Eq_d0'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final captions = data['captions']?['playerCaptionsTracklistRenderer']?['captionTracks'];
      if (captions != null) {
        log('SUCCESS: Found ${captions.length} tracks!');
        log('First Track URL: ${captions[0]['baseUrl']}');
      } else {
        log('FAILED: No captions in JSON response. Data keys: ${data.keys.toList()}');
      }
    } else {
      log('FAILED: Status ${res.statusCode}');
    }
  } catch (e) {
    log('ERROR: $e');
  }

  // МЕТОД 2: TimedText Direct (Упрощенный)
  log('\n--- Method 2: TimedText Direct ---');
  try {
    final url = 'https://www.youtube.com/api/timedtext?v=$videoId&lang=en&fmt=json3';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      log('SUCCESS: TimedText returned data! Length: ${res.body.length}');
      log('Preview: ${res.body.substring(0, 100)}...');
    } else {
      log('FAILED: Status ${res.statusCode} or empty body');
    }
  } catch (e) {
    log('ERROR: $e');
  }

  await sink.close();
  print('\nDONE! Check subs_test_results.txt');
}
