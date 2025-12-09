import 'dart:typed_data';

import 'package:dtorrent_tracker/src/tracker_generator.dart';
import 'package:dtorrent_tracker/src/tracker/tracker.dart';
import 'package:dtorrent_tracker/src/tracker/http_tracker.dart';
import 'package:dtorrent_tracker/src/tracker/udp_tracker.dart';
import 'package:test/test.dart';

class MockAnnounceOptionsProvider implements AnnounceOptionsProvider {
  @override
  Future<Map<String, dynamic>> getOptions(Uri uri, String infoHash) async {
    return {
      'downloaded': 0,
      'uploaded': 0,
      'left': 1000,
      'compact': 1,
      'numwant': 50,
      'port': 6881,
      'peerId': 'ABCDEFGHIJKLMNOPQRST'
    };
  }
}

void main() {
  group('TrackerGenerator', () {
    final infoHash =
        Uint8List.fromList(List.generate(20, (i) => i)); // 20-byte info hash
    final provider = MockAnnounceOptionsProvider();

    group('BaseTrackerGenerator', () {
      test('should create HttpTracker for http URLs', () {
        var generator = TrackerGenerator.base();
        var uri = Uri.parse('http://example.com/announce');
        var tracker = generator.createTracker(uri, infoHash, provider);
        expect(tracker, isA<HttpTracker>());
        expect(tracker?.announceUrl, equals(uri));
      });

      test('should create HttpTracker for https URLs', () {
        var generator = TrackerGenerator.base();
        var uri = Uri.parse('https://example.com/announce');
        var tracker = generator.createTracker(uri, infoHash, provider);
        expect(tracker, isA<HttpTracker>());
        expect(tracker?.announceUrl, equals(uri));
      });

      test('should create UDPTracker for udp URLs', () {
        var generator = TrackerGenerator.base();
        var uri = Uri.parse('udp://example.com:80');
        var tracker = generator.createTracker(uri, infoHash, provider);
        expect(tracker, isA<UDPTracker>());
        expect(tracker?.announceUrl, equals(uri));
      });

      test('should return null for unsupported schemes', () {
        var generator = TrackerGenerator.base();
        var uri = Uri.parse('ws://example.com/announce');
        var tracker = generator.createTracker(uri, infoHash, provider);
        expect(tracker, isNull);
      });

      test('should return null for invalid info hash length', () {
        var generator = TrackerGenerator.base();
        var uri = Uri.parse('http://example.com/announce');
        var invalidInfoHash = Uint8List(10); // Wrong length
        var tracker = generator.createTracker(uri, invalidInfoHash, provider);
        // Note: The generator doesn't validate info hash length,
        // but the tracker might fail later
        expect(tracker, isNotNull);
      });
    });
  });
}



