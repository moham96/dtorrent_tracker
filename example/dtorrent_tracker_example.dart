import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dtorrent_common/dtorrent_common.dart';

import 'package:dtorrent_parser/dtorrent_parser.dart';
import 'package:dtorrent_tracker/dtorrent_tracker.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

var scriptDir = path.dirname(Platform.script.path);
var torrentsPath =
    path.canonicalize(path.join(scriptDir, '..', '..', '..', 'torrents'));

void main() async {
  var _log = Logger.root;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '[${record.loggerName}] ${record.level.name}: ${record.time}: ${record.message}');
  });
  var torrent =
      await Torrent.parse(path.join(torrentsPath, 'big-buck-bunny.torrent'));

  var id = generatePeerId();
  var port = 55551;
  var provider = SimpleProvider(torrent, id, port, torrent.infoHash);
  var peerAddress = <CompactAddress>{};
  print(provider.torrent);

  /// Announce Track:
  try {
    var torrentTracker = TorrentAnnounceTracker(provider, maxRetryTime: 0);
    var trackerListener = torrentTracker.createListener();
    trackerListener
      ..on<AnnounceTrackerDisposedEvent>((event) {
        // if (reason != null && source is HttpTracker)
        _log.info('Tracker disposed  , remain ${torrentTracker.trackersNum} :',
            event.reason);
      })
      ..on<AnnounceErrorEvent>(
        (event) {
          // log('announce error:', error: error);
          // source.dispose(error);
        },
      )
      ..on<AnnouncePeerEventEvent>(
        (event) {
          // print('${source.announceUrl} peer event: $event');
          if (event.event == null) return;
          peerAddress.addAll(event.event!.peers);
          event.source.dispose('Complete Announc');
          print('got ${peerAddress.length} peers');
        },
      )
      ..on<AnnounceOverEvent>(
        (event) {
          print('${event.source.announceUrl} announce over: ${event.time}');
          // source.dispose();
        },
      );

    findPublicTrackers().listen((urls) {
      torrentTracker.runTrackers(urls, torrent.infoHashBuffer);
    });

    // Timer(Duration(seconds: 120), () async {
    //   await torrentTracker.stop(true);
    //   print('completed $peerAddress');
    // });
  } catch (e) {
    print(e);
  }

  /// Scrape
  // var scrapeTracker = TorrentScrapeTracker();
  // scrapeTracker.addScrapes(torrent.announces, torrent.infoHashBuffer);
  // scrapeTracker.scrape(torrent.infoHashBuffer).listen((event) {
  //   print(event);
  // }, onError: (e) => log('error:', error: e, name: 'MAIN'));
}

class SimpleProvider implements AnnounceOptionsProvider {
  SimpleProvider(this.torrent, this.peerId, this.port, this.infoHash);
  String peerId;
  int port;
  String infoHash;
  Torrent torrent;
  int compact = 1;
  int numwant = 50;

  @override
  Future<Map<String, dynamic>> getOptions(Uri uri, String infoHash) {
    return Future.value({
      'downloaded': 0,
      'uploaded': 0,
      'left': torrent.length,
      'compact': compact,
      'numwant': numwant,
      'peerId': peerId,
      'port': port
    });
  }
}

String generatePeerId() {
  var r = randomBytes(9);
  var base64Str = base64Encode(r);
  var id = '-MURLIN-$base64Str';
  return id;
}
