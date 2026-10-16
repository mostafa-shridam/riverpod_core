import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/remote_config/app_gate.dart';
import 'package:riverpod_core/core/remote_config/remote_config.dart';

RemoteConfig _config({
  String minVersion = '1.0.0',
  String latestVersion = '1.5.0',
  bool maintenance = false,
}) => RemoteConfig(
  minVersion: minVersion,
  latestVersion: latestVersion,
  maintenance: RemoteMaintenance(enabled: maintenance),
);

void main() {
  group('gateStatusFor', () {
    final cases = <(String, RemoteConfig, AppGateStatus)>[
      ('1.5.0', _config(), AppGateStatus.ok),
      ('1.9.0', _config(), AppGateStatus.ok),
      ('1.4.9', _config(), AppGateStatus.updateAvailable),
      ('1.0.0', _config(), AppGateStatus.updateAvailable),
      ('0.9.9', _config(), AppGateStatus.updateRequired),
      ('1.10.0', _config(latestVersion: '1.9.0'), AppGateStatus.ok),
      (
        '1.2.0+7',
        _config(minVersion: '1.2.0+99'),
        AppGateStatus.updateAvailable,
      ),
      ('1.5.0', _config(maintenance: true), AppGateStatus.maintenance),
      ('0.1.0', _config(maintenance: true), AppGateStatus.maintenance),
      ('garbage', _config(), AppGateStatus.ok),
      ('1.0.0', _config(minVersion: 'garbage'), AppGateStatus.ok),
      ('0.0.0', RemoteConfig.defaults, AppGateStatus.ok),
    ];
    for (final (current, config, expected) in cases) {
      test('$current with min ${config.minVersion} and latest '
          '${config.latestVersion}${config.maintenance.enabled ? ' (maintenance)' : ''} '
          'is ${expected.name}', () {
        expect(
          gateStatusFor(currentVersion: current, config: config),
          expected,
        );
      });
    }
  });

  group('softUpdateDue', () {
    test('only for an available update the user has not dismissed', () {
      expect(
        softUpdateDue(
          status: AppGateStatus.updateAvailable,
          latestVersion: '1.5.0',
          dismissedVersions: const [],
        ),
        isTrue,
      );
      expect(
        softUpdateDue(
          status: AppGateStatus.updateAvailable,
          latestVersion: '1.5.0',
          dismissedVersions: const ['1.5.0'],
        ),
        isFalse,
        reason: 'dismissed for this version',
      );
      expect(
        softUpdateDue(
          status: AppGateStatus.updateAvailable,
          latestVersion: '1.6.0',
          dismissedVersions: const ['1.5.0'],
        ),
        isTrue,
        reason: 'a newer version asks again',
      );
    });

    test('never for ok, forced or maintenance states', () {
      for (final status in [
        AppGateStatus.ok,
        AppGateStatus.updateRequired,
        AppGateStatus.maintenance,
      ]) {
        expect(
          softUpdateDue(
            status: status,
            latestVersion: '1.5.0',
            dismissedVersions: const [],
          ),
          isFalse,
          reason: status.name,
        );
      }
    });
  });
}
