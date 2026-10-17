import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';
import 'package:riverpod_core/core/crash/crash_reporter.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'collection_consent.g.dart';

/// Device-level key (survives logout on purpose: consent is not user data).
const collectionConsentKey = 'settings.collectionConsent';

/// Value used until the user chooses. An app that needs opt-in consent flips
/// it here, in one place.
const defaultCollectionConsent = true;

/// The runtime consent switch for crash and analytics collection. The
/// per-flavor `ENABLE_*` flags still decide whether a vendor runs at all; an
/// app shows a switch bound to [setEnabled].
@Riverpod(keepAlive: true)
class CollectionConsent extends _$CollectionConsent {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    final value =
        prefs.getBool(collectionConsentKey) ?? defaultCollectionConsent;
    await _apply(value);
    return value;
  }

  /// Saves the choice and tells the crash and analytics vendors.
  Future<void> setEnabled({required bool value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(collectionConsentKey, value);
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
