/// Current time. Injected so tests never read the real clock.
typedef Clock = DateTime Function();

/// Whether an entry saved at [savedAt] is older than [ttl] at [now].
bool isExpired({
  required DateTime savedAt,
  required Duration ttl,
  required DateTime now,
}) => now.difference(savedAt) > ttl;

/// Storage key for [key]. User-scoped data is prefixed with the user id, so
/// one user's entries can be removed without touching another's.
String cacheKey(String key, {String? userId}) =>
    userId == null ? 'shared/$key' : 'user/$userId/$key';
