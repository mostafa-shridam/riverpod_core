import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';
import 'package:riverpod_core/core/crash/crash_reporter.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

part 'collection_consent.g.dart';

/// Value used until the user chooses. An app that needs opt-in consent flips
/// it here, in one place.
const defaultCollectionConsent = true;

/// The runtime consent switch for crash and analytics collection. The
/// per-flavor `ENABLE_*` flags still decide whether a vendor runs at all; an
/// app shows a switch bound to [setEnabled]. The choice is device-level, so it
/// survives logout (see [PrefsStorage.collectionConsent]).
@Riverpod(keepAlive: true)
class CollectionConsent extends _$CollectionConsent {
  @override
  Future<bool> build() async {
    final prefs = await ref.read(prefsStorageProvider.future);
    final value = prefs.collectionConsent ?? defaultCollectionConsent;
    await _apply(value);
    return value;
  }

  /// Saves the choice and tells the crash and analytics vendors.
  Future<void> setEnabled({required bool value}) async {
    final prefs = await ref.read(prefsStorageProvider.future);
    await prefs.setCollectionConsent(value: value);
    state = AsyncData(value);
    await _apply(value);
  }

  Future<void> _apply(bool value) async {
    await ref.read(crashReporterProvider).setCollectionEnabled(enabled: value);
    await ref
        .read(analyticsServiceProvider)
        .setCollectionEnabled(enabled: value);
  }
}
