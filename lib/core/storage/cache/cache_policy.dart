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

/// A retention preset (D-038): [ttl] is how long a copy counts as fresh, and
/// [maxAge] is how long an entry may go unvalidated before pruning removes it.
/// Features pick a preset; nobody hand-rolls expiry.
class CachePolicy {
  const CachePolicy({required this.ttl, required this.maxAge});

  /// Minutes of freshness: feeds and anything that changes often.
  static const short = CachePolicy(
    ttl: Duration(minutes: 5),
    maxAge: Duration(days: 1),
  );

  /// Hours of freshness: the default for lists and details.
  static const medium = CachePolicy(
    ttl: Duration(hours: 1),
    maxAge: Duration(days: 7),
  );

  /// Days of freshness: reference data that changes slowly.
  static const long = CachePolicy(
    ttl: Duration(days: 1),
    maxAge: Duration(days: 30),
  );

  /// Weeks of freshness: data that almost never changes.
  static const static = CachePolicy(
    ttl: Duration(days: 7),
    maxAge: Duration(days: 90),
  );

  final Duration ttl;
  final Duration maxAge;
}
