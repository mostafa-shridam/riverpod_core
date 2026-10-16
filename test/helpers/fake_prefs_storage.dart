import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [PrefsStorage] backed by `shared_preferences` mock values. Pass [initial]
/// to seed it. Each call starts from a clean mock store.
Future<PrefsStorage> fakePrefsStorage([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  return PrefsStorage(await SharedPreferences.getInstance());
}
