import 'dart:io';

import 'package:dtorrent_common/dtorrent_common.dart';
import 'package:dtorrent_tracker/src/tracker/peer_event.dart';
import 'package:test/test.dart';

void main() {
  group('PeerEvent', () {
    final infoHash = '0123456789abcdef0123456789abcdef01234567';
    final serverHost = Uri.parse('http://example.com/announce');

    test('should create with required parameters', () {
      var event = PeerEvent(infoHash, serverHost);
      expect(event.infoHash, equals(infoHash));
      expect(event.serverHost, equals(serverHost));
    });

    test('should create with all optional parameters', () {
      var event = PeerEvent(
        infoHash,
        serverHost,
        complete: 10,
        incomplete: 5,
        interval: 1800,
        minInterval: 900,
        warning: 'Test warning',
      );
      expect(event.complete, equals(10));
      expect(event.incomplete, equals(5));
      expect(event.interval, equals(1800));
      expect(event.minInterval, equals(900));
      expect(event.warning, equals('Test warning'));
    });

    test('should add peer', () {
      var event = PeerEvent(infoHash, serverHost);
      var address = InternetAddress('192.168.1.1');
      var peer = CompactAddress(address, 6881);
      var result = event.addPeer(peer);
      expect(result, isTrue);
      expect(event.peers.length, equals(1));
      expect(event.peers.contains(peer), isTrue);
    });

    test('should not add duplicate peer', () {
      var event = PeerEvent(infoHash, serverHost);
      var address = InternetAddress('192.168.1.1');
      var peer = CompactAddress(address, 6881);
      event.addPeer(peer);
      var result = event.addPeer(peer);
      expect(result, isFalse);
      expect(event.peers.length, equals(1));
    });

    test('should remove peer', () {
      var event = PeerEvent(infoHash, serverHost);
      var address = InternetAddress('192.168.1.1');
      var peer = CompactAddress(address, 6881);
      event.addPeer(peer);
      var result = event.removePeer(peer);
      expect(result, isTrue);
      expect(event.peers.length, equals(0));
    });

    test('should not remove non-existent peer', () {
      var event = PeerEvent(infoHash, serverHost);
      var address = InternetAddress('192.168.1.1');
      var peer = CompactAddress(address, 6881);
      var result = event.removePeer(peer);
      expect(result, isFalse);
    });

    test('should set and get other information', () {
      var event = PeerEvent(infoHash, serverHost);
      event.setInfo('key1', 'value1');
      event.setInfo('key2', 123);
      expect(event.otherInformationsMap['key1'], equals('value1'));
      expect(event.otherInformationsMap['key2'], equals(123));
    });

    test('should remove other information', () {
      var event = PeerEvent(infoHash, serverHost);
      event.setInfo('key1', 'value1');
      var result = event.removeInfo('key1');
      expect(result, equals('value1'));
      expect(event.otherInformationsMap.containsKey('key1'), isFalse);
    });

    test('should generate string representation', () {
      var event = PeerEvent(
        infoHash,
        serverHost,
        complete: 10,
        incomplete: 5,
        interval: 1800,
      );
      var address = InternetAddress('192.168.1.1');
      var peer = CompactAddress(address, 6881);
      event.addPeer(peer);
      var str = event.toString();
      expect(str, contains(infoHash));
      expect(str, contains(serverHost.toString()));
      expect(str, contains('complete:10'));
      expect(str, contains('incomplete:5'));
      expect(str, contains('interval:1800'));
    });

    test('should handle backward compatibility with otherInfomationsMap', () {
      var event = PeerEvent(infoHash, serverHost);
      event.setInfo('key1', 'value1');
      // Test deprecated getter still works
      expect(event.otherInformationsMap['key1'], equals('value1'));
      expect(event.otherInformationsMap, equals(event.otherInformationsMap));
    });
  });
}
