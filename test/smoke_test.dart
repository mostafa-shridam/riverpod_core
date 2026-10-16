import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/themes/style.dart';

void main() {
  test('light and dark themes build', () {
    expect(getLightTheme().useMaterial3, isTrue);
    expect(getDarkTheme().useMaterial3, isTrue);
  });
}
