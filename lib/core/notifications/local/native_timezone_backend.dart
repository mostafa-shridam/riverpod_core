import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';
import 'package:riverpod_core/core/notifications/local/timezone_backend.dart';

/// [TimezoneBackend] over `flutter_native_timezone_latest`.
class NativeTimezoneBackend implements TimezoneBackend {
  const NativeTimezoneBackend();

  @override
  Future<String?> localTimezone() async {
    try {
      return await FlutterNativeTimezoneLatest.getLocalTimezone();
    } on Object {
      return null;
    }
  }
}
