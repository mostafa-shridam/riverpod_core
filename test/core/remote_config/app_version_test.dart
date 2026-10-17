import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/remote_config/app_version.dart';

void main() {
  group('compareVersions', () {
    final cases = <(String, String, int)>[
      ('1.10.0', '1.9.0', 1),
      ('1.9.0', '1.10.0', -1),
      ('2.0.0', '1.99.99', 1),
      ('1.2.3', '1.2.3', 0),
      ('1.2', '1.2.0', 0),
      ('1', '0.9.9', 1),
      ('1.2.3+45', '1.2.3+99', 0),
      ('1.2.3+1', '1.2.2', 1),
      ('0.0.0', '0.0.1', -1),
    ];
    for (final (a, b, expected) in cases) {
      test('$a vs $b is ${expected.sign}', () {
        expect(compareVersions(a, b).sign, expected);
      });
    }

    test('anything that is not a version throws', () {
      for (final bad in ['', 'a.b', '1..2', '1.2.3.4', '-1.0.0', '1.2-beta']) {
        expect(
          () => compareVersions(bad, '1.0.0'),
          throwsFormatException,
          reason: bad,
        );
      }
    });
  });
}
