/// Source of the device's IANA time zone name (`Africa/Cairo`). Tests use a
/// fake.
abstract interface class TimezoneBackend {
  /// The local zone name, or null when the platform cannot tell.
  Future<String?> localTimezone();
}
