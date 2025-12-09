/// The tracker base event.
class TrackerEventBase {
  final Map _others = {};

  /// Get other information map
  Map get otherInformationsMap {
    return _others;
  }

  void setInfo(key, value) {
    _others[key] = value;
  }

  dynamic removeInfo(key) {
    return _others.remove(key);
  }
}
