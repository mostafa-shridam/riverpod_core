import 'package:riverpod_core/bootstrap.dart';
import 'package:riverpod_core/core/config/flavor.dart';

/// Staging build: `flutter run -t lib/main_staging.dart` (D-024).
Future<void> main() => bootstrap(Flavor.staging);
