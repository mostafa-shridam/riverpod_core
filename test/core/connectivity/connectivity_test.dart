import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/connectivity/connectivity_provider.dart';
import 'package:riverpod_core/core/connectivity/connectivity_service.dart';

import '../../helpers/create_container.dart';
import '../../helpers/fake_connectivity.dart';

void main() {
  group('connectivityStatusOf', () {
    test('empty list and only none are offline', () {
      expect(connectivityStatusOf([]), ConnectivityStatus.offline);
      expect(
        connectivityStatusOf([ConnectivityResult.none]),
        ConnectivityStatus.offline,
      );
    });

    test('any real interface is online', () {
      expect(
        connectivityStatusOf([ConnectivityResult.wifi]),
        ConnectivityStatus.online,
      );
      expect(
        connectivityStatusOf([
          ConnectivityResult.mobile,
          ConnectivityResult.vpn,
        ]),
        ConnectivityStatus.online,
      );
    });
  });

  group('connectivityProvider', () {
    test('starts with the checked status', () async {
      final fake = FakeConnectivity(online: false);
      final container = createContainer(overrides: [fake.providerOverride]);
      final sub = container.listen(connectivityProvider, (_, _) {});
      addTearDown(sub.close);
      expect(
        await container.read(connectivityProvider.future),
        ConnectivityStatus.offline,
      );
    });

    test('follows plugin events and drops repeats', () async {
      final fake = FakeConnectivity();
      final container = createContainer(overrides: [fake.providerOverride]);
      final seen = <ConnectivityStatus>[];
      container.listen(connectivityProvider, (_, next) {
        if (next.hasValue) seen.add(next.requireValue);
      });
      await container.read(connectivityProvider.future);
      fake.setOnline(false);
      await pumpEventQueue();
      fake.setOnline(false);
      await pumpEventQueue();
      fake.setOnline(true);
      await pumpEventQueue();
      expect(seen, [
        ConnectivityStatus.online,
        ConnectivityStatus.offline,
        ConnectivityStatus.online,
      ]);
    });
  });

  group('backOnlineProvider', () {
    test('emits a counter only on offline to online', () async {
      final fake = FakeConnectivity();
      final container = createContainer(overrides: [fake.providerOverride]);
      final events = <int>[];
      container.listen(backOnlineProvider, (_, next) {
        if (next.hasValue) events.add(next.requireValue);
      });
      await container.read(connectivityProvider.future);
      await pumpEventQueue();
      expect(events, isEmpty);

      fake.setOnline(false);
      await pumpEventQueue();
      expect(events, isEmpty);

      fake.setOnline(true);
      await pumpEventQueue();
      expect(events, [1]);

      fake.setOnline(false);
      await pumpEventQueue();
      fake.setOnline(true);
      await pumpEventQueue();
      expect(events, [1, 2]);
    });
  });
}
