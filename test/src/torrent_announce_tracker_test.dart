import 'dart:async';
import 'dart:typed_data';

import 'package:dtorrent_tracker/src/torrent_announce_tracker.dart';
import 'package:dtorrent_tracker/src/tracker/tracker.dart';
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
  group('TorrentAnnounceTracker', () {
    final infoHash =
        Uint8List.fromList(List.generate(20, (i) => i)); // 20-byte info hash
    final provider = MockAnnounceOptionsProvider();

    test('should create with default tracker generator', () {
      var tracker = TorrentAnnounceTracker(provider);
      expect(tracker.trackerGenerator, isNotNull);
      expect(tracker.provider, equals(provider));
    });

    test('should create with custom max retry time', () {
      var tracker = TorrentAnnounceTracker(provider, maxRetryTime: 5);
      expect(tracker.maxRetryTime, equals(5));
    });

    test('should have zero trackers initially', () {
      var tracker = TorrentAnnounceTracker(provider);
      expect(tracker.trackersNum, equals(0));
    });

    test('should run tracker for http URL', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      tracker.runTracker(uri, infoHash);
      expect(tracker.trackersNum, equals(1));
    });

    test('should run tracker for https URL', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('https://example.com/announce');
      tracker.runTracker(uri, infoHash);
      expect(tracker.trackersNum, equals(1));
    });

    test('should run tracker for udp URL', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('udp://example.com:80');
      tracker.runTracker(uri, infoHash);
      expect(tracker.trackersNum, equals(1));
    });

    test('should not create tracker for invalid info hash', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      var invalidInfoHash = Uint8List(10); // Wrong length
      tracker.runTracker(uri, invalidInfoHash);
      expect(tracker.trackersNum, equals(0));
    });

    test('should not create duplicate trackers for same URL', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      tracker.runTracker(uri, infoHash);
      tracker.runTracker(uri, infoHash);
      expect(tracker.trackersNum, equals(1));
    });

    test('should run multiple trackers', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uris = [
        Uri.parse('http://example.com/announce'),
        Uri.parse('http://tracker2.com/announce'),
      ];
      tracker.runTrackers(uris, infoHash);
      expect(tracker.trackersNum, equals(2));
    });

    test('should remove tracker', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      tracker.runTracker(uri, infoHash);
      expect(tracker.trackersNum, equals(1));
      tracker.removeTracker(uri);
      expect(tracker.trackersNum, equals(0));
    });

    test('should handle restart tracker', () async {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      tracker.runTracker(uri, infoHash);
      var result = tracker.restartTracker(uri);
      expect(result, isTrue);
    });

    test('should return false when restarting non-existent tracker', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      var result = tracker.restartTracker(uri);
      expect(result, isFalse);
    });

    test('should restart all trackers', () async {
      var tracker = TorrentAnnounceTracker(provider);
      var uris = [
        Uri.parse('http://example.com/announce'),
        Uri.parse('http://tracker2.com/announce'),
      ];
      tracker.runTrackers(uris, infoHash);
      var results = await tracker.restartAll();
      expect(results.length, equals(2));
    });

    test('should handle stop', () async {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      tracker.runTracker(uri, infoHash);
      var results = await tracker.stop();
      expect(results, isNotNull);
    });

    test('should handle complete', () async {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      tracker.runTracker(uri, infoHash);
      var results = await tracker.complete();
      expect(results, isNotNull);
    });

    test('should handle dispose', () async {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      tracker.runTracker(uri, infoHash);
      await tracker.dispose();
      expect(tracker.isDisposed, isTrue);
    });

    test('should not run tracker after dispose', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      tracker.runTracker(uri, infoHash);
      tracker.dispose();
      var newUri = Uri.parse('http://tracker2.com/announce');
      tracker.runTracker(newUri, infoHash);
      expect(tracker.trackersNum, lessThanOrEqualTo(1));
    });

    test('should handle event types', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      tracker.runTracker(uri, infoHash, event: EVENT_STARTED);
      expect(tracker.trackersNum, equals(1));
      tracker.runTracker(uri, infoHash, event: EVENT_STOPPED);
      tracker.runTracker(uri, infoHash, event: EVENT_COMPLETED);
    });

    test('should handle force stop', () {
      var tracker = TorrentAnnounceTracker(provider);
      var uri = Uri.parse('http://example.com/announce');
      tracker.runTracker(uri, infoHash, event: EVENT_STOPPED, force: true);
      expect(tracker.trackersNum, equals(1));
    });
  });
}



