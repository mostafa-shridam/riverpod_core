/// Thrown when the env configuration (`env/<flavor>.env`) is missing or invalid.
///
/// [problems] lists every problem found, not just the first one, so the developer
/// can fix the env file in one pass.
class ConfigException implements Exception {
  const ConfigException(this.problems);

  final List<String> problems;

  @override
  String toString() {
    final buffer = StringBuffer('Invalid app configuration:');
    for (final problem in problems) {
      buffer.write('\n  - $problem');
    }
    buffer.write('\nFix env/<flavor>.env (copy env/<flavor>.env.example).');
    return buffer.toString();
  }
}
