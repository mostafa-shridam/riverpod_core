import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_value_view.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';

import '../../../../helpers/fake_connectivity.dart';
import '../display/ds_test_harness.dart';

final _stamp = DateTime(2026, 3, 14, 9, 30);
const _items = AsyncData<List<String>>(['Alpha', 'Beta', 'Gamma']);

class _Case {
  const _Case(
    this.name,
    this.value, {
    this.offline = false,
    this.isEmpty = false,
    this.isStale = false,
    this.partial = false,
  });

  final String name;
  final AsyncValue<List<String>> value;
  final bool offline;
  final bool isEmpty;
  final bool isStale;
  final bool partial;

  bool get isRefreshing => value.isLoading && value.hasValue;
}

final _cases = <_Case>[
  const _Case('loading', AsyncLoading()),
  const _Case('empty', AsyncData(<String>[]), isEmpty: true),
  const _Case(
    'error',
    AsyncError(ServerException(statusCode: 500), StackTrace.empty),
  ),
  const _Case(
    'offline',
    AsyncError(NetworkException(), StackTrace.empty),
    offline: true,
  ),
  const _Case('stale', _items, isStale: true),
  const _Case('partial', _items, partial: true),
  _Case(
    'refreshing',
    // ignore: invalid_use_of_internal_member
    const AsyncLoading<List<String>>().copyWithPrevious(_items),
  ),
  const _Case('success', _items),
];

Widget _page(_Case c) => ProviderScope(
  overrides: [FakeConnectivity(online: !c.offline).providerOverride],
  child: AsyncValueView<List<String>>(
    value: c.value,
    isEmpty: c.isEmpty,
    isStale: c.isStale,
    hasPartialError: c.partial,
    lastUpdated: c.isStale ? _stamp : null,
    onRetry: () {},
    builder: (context, data) => ListView(
      children: [
        for (final s in data)
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
            title: Text(s),
            subtitle: const Text('Item'),
          ),
      ],
    ),
  ),
);

void main() {
  for (final c in _cases) {
    for (final mode in goldenModes) {
      testWidgets('${c.name} ${mode.name}', (tester) async {
        await pumpDs(
          tester,
          _page(c),
          locale: mode.locale,
          dark: mode.dark,
          size: const Size(400, 640),
          // The refresh line animates forever, so it cannot settle.
          disableAnimations: !c.isRefreshing,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            '../../../../goldens/async/${c.name}_${mode.name}.png',
          ),
        );
      });
    }
  }

  for (final c in [_cases[1], _cases[3]]) {
    testWidgets('${c.name} text scale 2.0 tablet', (tester) async {
      await pumpDs(tester, _page(c), textScale: 2, size: const Size(800, 700));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          '../../../../goldens/async/${c.name}_scale2_tablet.png',
        ),
      );
    });
  }
}
