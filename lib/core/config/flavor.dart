import 'package:flutter/foundation.dart' show kReleaseMode;

/// The build flavors (D-024).
enum Flavor {
  dev,
  staging,
  prod;

  /// The flavor of this build: release builds are [prod], everything else
  /// [dev]. [staging] is chosen only by `lib/main_staging.dart`.
  static Flavor get current => resolve();

  /// Pure form of [current]; [isRelease] is injectable for tests.
  static Flavor resolve({bool isRelease = kReleaseMode}) =>
      isRelease ? Flavor.prod : Flavor.dev;
}
