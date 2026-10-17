import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/firebase/collection_consent.dart';
import 'package:riverpod_core/core/firebase/firebase_bootstrap.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';

/// Startup step for crash and analytics (D-042): starts Firebase when either
/// is enabled, records the result, then applies the saved consent to the
/// vendor services. Never throws; without Firebase files both stay Noop.
Future<void> initObservability(ProviderContainer container) async {
  final config = container.read(appConfigProvider);
  if (!config.enableCrashReporting && !config.enableAnalytics) return;
  final ready = await container
      .read(firebaseBootstrapProvider)
      .ensureInitialized();
  container
      .read(firebaseAvailableProvider.notifier)
      .markAvailable(value: ready);
  if (!ready) return;
  try {
    await container.read(collectionConsentProvider.future);
  } on Object catch (e, s) {
    // The vendors keep their default collection setting.
    container
        .read(loggerProvider)
        .warning('Collection consent not applied', error: e, stackTrace: s);
  }
}
