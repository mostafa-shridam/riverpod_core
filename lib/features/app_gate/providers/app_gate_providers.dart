import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/remote_config/app_gate.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:url_launcher/url_launcher.dart';

part 'app_gate_providers.g.dart';

/// Opens a URL outside the app (the store page). Override in tests.
typedef StoreOpener = Future<bool> Function(Uri uri);

@Riverpod(keepAlive: true)
StoreOpener storeOpener(Ref ref) =>
    (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

/// Newest versions the user dismissed the soft update notice for. Device
/// setting (not per user), read and written through `PrefsStorage`.
@Riverpod(keepAlive: true)
class DismissedUpdates extends _$DismissedUpdates {
  @override
  Future<List<String>> build() async {
    final prefs = await ref.watch(prefsStorageProvider.future);
    return prefs.dismissedUpdateVersions;
  }

  Future<void> dismiss(String version) async {
    final prefs = await ref.read(prefsStorageProvider.future);
    final next = {...prefs.dismissedUpdateVersions, version}.toList();
    await prefs.setDismissedUpdateVersions(next);
    state = AsyncData(next);
  }
}

/// Whether the soft update notice should show now: the build is behind the
/// latest version and the user has not dismissed that version. False while
/// the dismissals are still loading, so the notice never flashes.
@riverpod
bool softUpdateNotice(Ref ref) {
  final config = ref.watch(currentRemoteConfigProvider);
  final dismissed = ref.watch(dismissedUpdatesProvider).value;
  if (dismissed == null) return false;
  return softUpdateDue(
    status: ref.watch(appGateStatusProvider),
    latestVersion: config.latestVersion,
    dismissedVersions: dismissed,
  );
}
