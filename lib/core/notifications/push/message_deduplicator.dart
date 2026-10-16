import 'dart:collection';

/// Remembers the last message ids so the same push is handled once (FCM can
/// deliver the same message twice, for example to the initial-message and the
/// opened-app callbacks).
class MessageDeduplicator {
  MessageDeduplicator({this.capacity = 100});

  /// How many ids are remembered; the oldest is forgotten first.
  final int capacity;

  final LinkedHashSet<String> _seen = LinkedHashSet<String>();

  /// True when [id] was seen before. Remembers it otherwise. A null or empty
  /// id is never a duplicate: without an id nothing can be compared.
  bool isDuplicate(String? id) {
    if (id == null || id.isEmpty) return false;
    if (!_seen.add(id)) return true;
    if (_seen.length > capacity) _seen.remove(_seen.first);
    return false;
  }
}
