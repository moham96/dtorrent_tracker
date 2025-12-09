import 'dart:typed_data';

import 'package:dtorrent_tracker/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('Utils', () {
    group('transformToScrapeUrl', () {
      test('should transform announce URL to scrape URL', () {
        var announceUrl = 'http://example.com/announce';
        var scrapeUrl = transformToScrapeUrl(announceUrl);
        expect(scrapeUrl, equals('http://example.com/scrape'));
      });

      test('should handle announce URL with query parameters', () {
        var announceUrl = 'http://example.com/announce?key=value';
        var scrapeUrl = transformToScrapeUrl(announceUrl);
        expect(scrapeUrl, equals('http://example.com/scrape?key=value'));
      });

      test('should handle announce URL with trailing slash', () {
        var announceUrl = 'http://example.com/announce/';
        var scrapeUrl = transformToScrapeUrl(announceUrl);
        // The function removes trailing slashes, so expect without slash
        expect(scrapeUrl, equals('http://example.com/scrape'));
      });

      test('should return null for URL without announce', () {
        var url = 'http://example.com/tracker';
        var scrapeUrl = transformToScrapeUrl(url);
        expect(scrapeUrl, isNull);
      });

      test('should handle URL ending with announce', () {
        var announceUrl = 'http://example.com/announce';
        var scrapeUrl = transformToScrapeUrl(announceUrl);
        expect(scrapeUrl, equals('http://example.com/scrape'));
      });
    });

    group('num2Uint16List', () {
      test('should convert number to Uint16List', () {
        var result = num2Uint16List(12345);
        expect(result.length, equals(2));
        var view = ByteData.view(result.buffer);
        expect(view.getUint16(0, Endian.big), equals(12345));
      });

      test('should handle zero', () {
        var result = num2Uint16List(0);
        expect(result.length, equals(2));
        var view = ByteData.view(result.buffer);
        expect(view.getUint16(0, Endian.big), equals(0));
      });
    });

    group('num2Uint32List', () {
      test('should convert number to Uint32List', () {
        var result = num2Uint32List(123456789);
        expect(result.length, equals(4));
        var view = ByteData.view(result.buffer);
        expect(view.getUint32(0, Endian.big), equals(123456789));
      });

      test('should handle zero', () {
        var result = num2Uint32List(0);
        expect(result.length, equals(4));
        var view = ByteData.view(result.buffer);
        expect(view.getUint32(0, Endian.big), equals(0));
      });
    });

    group('num2Uint64List', () {
      test('should convert number to Uint64List', () {
        var result = num2Uint64List(1234567890123456789);
        expect(result.length, equals(8));
        var view = ByteData.view(result.buffer);
        expect(view.getUint64(0, Endian.big), equals(1234567890123456789));
      });

      test('should handle zero', () {
        var result = num2Uint64List(0);
        expect(result.length, equals(8));
        var view = ByteData.view(result.buffer);
        expect(view.getUint64(0, Endian.big), equals(0));
      });
    });

    group('getPeerIPv4', () {
      test('should parse IPv4 address and port from ByteData', () {
        var buffer = Uint8List(6);
        buffer[0] = 192;
        buffer[1] = 168;
        buffer[2] = 1;
        buffer[3] = 1;
        buffer[4] = 0x13;
        buffer[5] = 0x88; // 5000 in big endian
        var view = ByteData.view(buffer.buffer);
        var uri = getPeerIPv4(view);
        expect(uri.host, equals('192.168.1.1'));
        expect(uri.port, equals(5000));
      });

      test('should handle offset', () {
        var buffer = Uint8List(10);
        buffer[4] = 10;
        buffer[5] = 0;
        buffer[6] = 0;
        buffer[7] = 1;
        buffer[8] = 0x04;
        buffer[9] = 0xD2; // 1234 in big endian
        var view = ByteData.view(buffer.buffer);
        var uri = getPeerIPv4(view, 4);
        expect(uri.host, equals('10.0.0.1'));
        expect(uri.port, equals(1234));
      });
    });
  });
}



