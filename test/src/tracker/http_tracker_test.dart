import 'dart:typed_data';

import 'package:b_encode_decode/b_encode_decode.dart';
import 'package:dtorrent_tracker/src/tracker/http_tracker.dart';
import 'package:test/test.dart';

void main() {
  group('HttpTracker.processResponseData', () {
    final uri = Uri.parse(_testAnnounce);
    final infoHashBuffer = hexString2Buffer(_testInfoHashString)!;
    final infoHashU8List = Uint8List.fromList(infoHashBuffer);
    final httpTracker = HttpTracker(uri, infoHashU8List);

    // setUp(() {});

    test('_fillPeers with Uint8List', () {
      final inputDataAsString = String.fromCharCodes(_uint8peersData);
      print('💡inputDataAsString: $inputDataAsString');
      final decoded = decode(_uint8peersData) as Map;
      print('💡decoded u8peers: $decoded');
      expect(decoded['peers'] is Uint8List, true);
      final res = httpTracker.processResponseData(_uint8peersData);
      expect(res.peers.isNotEmpty, true);
      expect(res.peers.length, 4);
      expect(res.interval, 3371);
      expect(res.minInterval, 3371);
    });
    test('_fillPeers with List<Map>', () {
      final inputDataAsString = String.fromCharCodes(_mapPeersData);
      print('💡inputDataAsString: $inputDataAsString');
      final decoded = decode(_mapPeersData) as Map;
      print('💡decoded List peers: $decoded');
      expect(decoded['peers'] is! Uint8List, true);
      final res = httpTracker.processResponseData(_mapPeersData);
      expect(res.peers.isNotEmpty, true);
      expect(res.peers.length, 2);
      expect(res.complete, 0);
      expect(res.incomplete, 2);
      expect(res.interval, 20);
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

const _testAnnounce =
    'http://bt.t-ru.org/ann?pk=76a9f26aac4c1bdbe997327ae6e7a928';
const _testInfoHashString = '9ebab45b516418b5309d97d7e1066f7e737822b1';

final _uint8peersData = Uint8List.fromList([
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

final _mapPeersData = Uint8List.fromList([
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
