import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Whether the device has a network interface up. This is the link state
/// reported by the OS, not proof that a given server is reachable: request
/// failures are still handled by `AppException`.
enum ConnectivityStatus { online, offline }

/// Maps the plugin's result list to a [ConnectivityStatus]. An empty list or
/// only `none` means offline.
ConnectivityStatus connectivityStatusOf(List<ConnectivityResult> results) {
  final offline =
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);
  return offline ? ConnectivityStatus.offline : ConnectivityStatus.online;
}

/// Thin wrapper over `connectivity_plus`. No DNS lookups and no third-party
/// hosts: it only reads plugin state and events. Tests override it with
/// `FakeConnectivity`.
class ConnectivityService {
  ConnectivityService({Connectivity? plugin}) : _plugin = plugin;

  Connectivity? _plugin;

  // Lazy so that creating the service never touches a platform channel.
  Connectivity get _connectivity => _plugin ??= Connectivity();

  /// Current status.
  Future<ConnectivityStatus> check() async =>
      connectivityStatusOf(await _connectivity.checkConnectivity());

  /// Status after every change reported by the plugin.
  Stream<ConnectivityStatus> get changes =>
      _connectivity.onConnectivityChanged.map(connectivityStatusOf);
}

/// The one [ConnectivityService] of the app.
@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) => ConnectivityService();
