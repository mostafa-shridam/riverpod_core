import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/connectivity/connectivity_service.dart';

/// In-memory [ConnectivityService]: flip it with [setOnline]. Use
/// [override] in `pumpApp`/`createContainer`.
class FakeConnectivity extends ConnectivityService {
  FakeConnectivity({bool online = true})
    : _status = online
          ? ConnectivityStatus.online
          : ConnectivityStatus.offline {
    addTearDown(_controller.close);
  }

  final _controller = StreamController<ConnectivityStatus>.broadcast();
  ConnectivityStatus _status;

  /// Overrides `connectivityServiceProvider` with this fake.
  Override get providerOverride =>
      connectivityServiceProvider.overrideWithValue(this);

  /// Changes the status and emits it like a plugin event.
  void setOnline(bool online) {
    _status = online ? ConnectivityStatus.online : ConnectivityStatus.offline;
    _controller.add(_status);
  }

  @override
  Future<ConnectivityStatus> check() async => _status;

  @override
  Stream<ConnectivityStatus> get changes => _controller.stream;
}
