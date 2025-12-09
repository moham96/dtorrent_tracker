import 'package:dtorrent_tracker/src/scraper_generator.dart';
import 'package:dtorrent_tracker/src/tracker/http_scrape.dart';
import 'package:dtorrent_tracker/src/tracker/udp_scrape.dart';
import 'package:test/test.dart';

void main() {
  group('ScraperGenerator', () {
    group('BaseScraperGenerator', () {
      test('should create HttpScrape for http URLs', () {
        var generator = ScraperGenerator.base();
        var uri = Uri.parse('http://example.com/announce');
        var scrape = generator.createScrape(uri);
        expect(scrape, isA<HttpScrape>());
        expect(scrape?.scrapeUrl.toString(), contains('scrape'));
      });

      test('should create HttpScrape for https URLs', () {
        var generator = ScraperGenerator.base();
        var uri = Uri.parse('https://example.com/announce');
        var scrape = generator.createScrape(uri);
        expect(scrape, isA<HttpScrape>());
        expect(scrape?.scrapeUrl.toString(), contains('scrape'));
      });

      test('should create UDPScrape for udp URLs', () {
        var generator = ScraperGenerator.base();
        var uri = Uri.parse('udp://example.com:80');
        var scrape = generator.createScrape(uri);
        expect(scrape, isA<UDPScrape>());
        expect(scrape?.scrapeUrl, equals(uri));
      });

      test('should return null for URLs without announce', () {
        var generator = ScraperGenerator.base();
        var uri = Uri.parse('http://example.com/tracker');
        var scrape = generator.createScrape(uri);
        expect(scrape, isNull);
      });

      test('should handle announce URL with query parameters', () {
        var generator = ScraperGenerator.base();
        var uri = Uri.parse('http://example.com/announce?key=value');
        var scrape = generator.createScrape(uri);
        expect(scrape, isA<HttpScrape>());
        expect(scrape?.scrapeUrl.toString(), contains('scrape'));
        expect(scrape?.scrapeUrl.toString(), contains('key=value'));
      });
    });
  });
}



