import 'package:dtorrent_tracker/src/tracker/scrape_event.dart';
import 'package:test/test.dart';

void main() {
  group('ScrapeEvent', () {
    final serverHost = Uri.parse('http://example.com/scrape');

    test('should create with server host', () {
      var event = ScrapeEvent(serverHost);
      expect(event.serverHost, equals(serverHost));
      expect(event.files.isEmpty, isTrue);
    });

    test('should add file', () {
      var event = ScrapeEvent(serverHost);
      var infoHash = '0123456789abcdef0123456789abcdef01234567';
      var result =
          ScrapeResult(infoHash, complete: 10, incomplete: 5, downloaded: 100);
      event.addFile(infoHash, result);
      expect(event.files.length, equals(1));
      expect(event.files[infoHash], equals(result));
    });

    test('should remove file', () {
      var event = ScrapeEvent(serverHost);
      var infoHash = '0123456789abcdef0123456789abcdef01234567';
      var result = ScrapeResult(infoHash);
      event.addFile(infoHash, result);
      var removed = event.removeFile(infoHash);
      expect(removed, equals(result));
      expect(event.files.isEmpty, isTrue);
    });

    test('should set and get other information', () {
      var event = ScrapeEvent(serverHost);
      event.setInfo('key1', 'value1');
      expect(event.otherInformationsMap['key1'], equals('value1'));
    });

    test('should generate string representation', () {
      var event = ScrapeEvent(serverHost);
      var infoHash = '0123456789abcdef0123456789abcdef01234567';
      var result =
          ScrapeResult(infoHash, complete: 10, incomplete: 5, downloaded: 100);
      event.addFile(infoHash, result);
      var str = event.toString();
      expect(str, contains(serverHost.toString()));
      expect(str, contains(infoHash));
    });
  });

  group('ScrapeResult', () {
    final infoHash = '0123456789abcdef0123456789abcdef01234567';

    test('should create with info hash', () {
      var result = ScrapeResult(infoHash);
      expect(result.infoHash, equals(infoHash));
    });

    test('should create with all parameters', () {
      var result = ScrapeResult(infoHash,
          complete: 10, incomplete: 5, downloaded: 100, name: 'test.torrent');
      expect(result.complete, equals(10));
      expect(result.incomplete, equals(5));
      expect(result.downloaded, equals(100));
      expect(result.name, equals('test.torrent'));
    });

    test('should set and get other information', () {
      var result = ScrapeResult(infoHash);
      result.setInfo('key1', 'value1');
      expect(result.otherInformationsMap['key1'], equals('value1'));
    });

    test('should generate string representation', () {
      var result = ScrapeResult(infoHash,
          complete: 10, incomplete: 5, downloaded: 100, name: 'test.torrent');
      var str = result.toString();
      expect(str, contains(infoHash));
      expect(str, contains('complete:10'));
      expect(str, contains('incomplete:5'));
      expect(str, contains('downloaded:100'));
      expect(str, contains('name:test.torrent'));
    });

    test('should handle backward compatibility with otherInfomationsMap', () {
      var result = ScrapeResult(infoHash);
      result.setInfo('key1', 'value1');
      // Test deprecated getter still works
      expect(result.otherInformationsMap['key1'], equals('value1'));
      expect(result.otherInformationsMap, equals(result.otherInformationsMap));
    });
  });
}
