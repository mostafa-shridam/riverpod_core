import 'package:riverpod_core/core/bootstrap/bootstrap.dart';
import 'package:riverpod_core/core/config/flavor.dart';

/// dev in debug/profile, prod in release (D-024).
void main() => bootstrap(Flavor.current);
