/// Compares `major.minor.patch` versions by number, so `1.10.0 > 1.9.0`. A
/// build number after `+` is ignored and missing parts count as 0.
///
/// Throws [FormatException] when either side is not a version.
int compareVersions(String a, String b) {
  final left = _parse(a);
  final right = _parse(b);
  for (var i = 0; i < 3; i++) {
    final diff = left[i].compareTo(right[i]);
    if (diff != 0) return diff;
  }
  return 0;
}

final _part = RegExp(r'^\d+$');

List<int> _parse(String version) {
  final core = version.split('+').first.trim();
  final parts = core.split('.');
  if (parts.length > 3 || parts.any((part) => !_part.hasMatch(part))) {
    throw FormatException('Not a version: $version', version);
  }
  final numbers = [for (final part in parts) int.parse(part)];
  while (numbers.length < 3) {
    numbers.add(0);
  }
  return numbers;
}
