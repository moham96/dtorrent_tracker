import 'dart:typed_data';

import 'package:b_encode_decode/b_encode_decode.dart';
import 'package:dtorrent_tracker/dtorrent_tracker.dart';
import 'package:test/test.dart';

void main() {
  final uri = Uri.parse(_testAnnounce);
  final infoHashBuffer = hexString2Buffer(_testInfoHashString)!;
  final infoHashU8List = Uint8List.fromList(infoHashBuffer);
  var httpTracker =
      HttpTracker(uri, infoHashU8List, provider: _MockOptionsProvider());

  group('HttpTracker.processResponseData', () {
    test('_fillPeers with Uint8List (BEP0023 compact)', () {
      final inputDataAsString = String.fromCharCodes(_bep0023compactPeersData);
      print('💡inputDataAsString: $inputDataAsString');
      final decoded = decode(_bep0023compactPeersData) as Map;
      print('💡decoded BEP0023 compact peers: $decoded');
      expect(decoded['peers'] is Uint8List, true);
      final res = httpTracker.processResponseData(_bep0023compactPeersData);
      expect(res.peers.isNotEmpty, true);
      expect(res.peers.length, 4);
      expect(res.interval, 3371);
      expect(res.minInterval, 3371);
    });
    test('_fillPeers with List<Map> (BEP003 non compact)', () {
      final inputDataAsString =
          String.fromCharCodes(_bep003nonCompactPeersData);
      print('💡inputDataAsString: $inputDataAsString');
      final decoded = decode(_bep003nonCompactPeersData) as Map;
      print('💡decoded BEP003 non compact peers: $decoded');
      expect(decoded['peers'] is! Uint8List, true);
      final res = httpTracker.processResponseData(_bep003nonCompactPeersData);
      expect(res.peers.isNotEmpty, true);
      expect(res.peers.length, 2);
      expect(res.complete, 0);
      expect(res.incomplete, 2);
      expect(res.interval, 20);
    });
  });

  group('HttpTracker: Send EVENT_COMPLETED and EVENT_STOPPED to announce', () {
    setUp(() => httpTracker =
        HttpTracker(uri, infoHashU8List, provider: _MockOptionsProvider()));

    test('Send EVENT_COMPLETED', () async {
      final res = await httpTracker.complete();
      expect(res != null, true);
    });
    test('Send EVENT_STOPPED', () async {
      final res = await httpTracker.stop();
      expect(res != null, true);
    });
  });
}

List<int>? hexString2Buffer(String hexStr) {
  if (hexStr.isEmpty || hexStr.length.remainder(2) != 0) return null;
  var size = hexStr.length ~/ 2;
  var re = <int>[];
  for (var i = 0; i < size; i++) {
    var s = hexStr.substring(i * 2, i * 2 + 2);
    var byte = int.parse(s, radix: 16);
    re.add(byte);
  }
  return re;
}

class _MockOptionsProvider implements AnnounceOptionsProvider {
  @override
  Future<Map<String, dynamic>> getOptions(Uri uri, String infoHash) {
    var map = {
      'downloaded': 0,
      'uploaded': 0,
      'left': 16 * 1024 * 20,
      'numwant': 50,
      'compact': 1,
      'peerId': '-DT0201-/8vC2ZjdAx5v',
      'port': 6881,
    };
    return Future.value(map);
  }
}

const _testAnnounce = 'http://nyaa.tracker.wf:7777/announce';
const _testInfoHashString = '69efaf354530d8cd7eb4edf434b30d8353240cac';

final _bep0023compactPeersData = Uint8List.fromList([
  100,
  56,
  58,
  105,
  110,
  116,
  101,
  114,
  118,
  97,
  108,
  105,
  51,
  51,
  55,
  49,
  101,
  49,
  50,
  58,
  109,
  105,
  110,
  32,
  105,
  110,
  116,
  101,
  114,
  118,
  97,
  108,
  105,
  51,
  51,
  55,
  49,
  101,
  53,
  58,
  112,
  101,
  101,
  114,
  115,
  50,
  52,
  58,
  46,
  71,
  223,
  59,
  254,
  124,
  46,
  71,
  223,
  59,
  26,
  225,
  95,
  31,
  0,
  102,
  77,
  221,
  193,
  194,
  100,
  16,
  146,
  131,
  101
]);

final _bep003nonCompactPeersData = Uint8List.fromList([
  100,
  56,
  58,
  99,
  111,
  109,
  112,
  108,
  101,
  116,
  101,
  105,
  48,
  101,
  49,
  48,
  58,
  105,
  110,
  99,
  111,
  109,
  112,
  108,
  101,
  116,
  101,
  105,
  50,
  101,
  56,
  58,
  105,
  110,
  116,
  101,
  114,
  118,
  97,
  108,
  105,
  50,
  48,
  101,
  53,
  58,
  112,
  101,
  101,
  114,
  115,
  108,
  100,
  50,
  58,
  105,
  112,
  49,
  51,
  58,
  55,
  55,
  46,
  50,
  52,
  54,
  46,
  49,
  53,
  57,
  46,
  49,
  49,
  52,
  58,
  112,
  111,
  114,
  116,
  105,
  53,
  49,
  52,
  49,
  51,
  101,
  101,
  100,
  50,
  58,
  105,
  112,
  49,
  50,
  58,
  54,
  50,
  46,
  49,
  54,
  53,
  46,
  55,
  46,
  49,
  48,
  52,
  52,
  58,
  112,
  111,
  114,
  116,
  105,
  49,
  52,
  48,
  56,
  50,
  101,
  101,
  101,
  101
]);
