import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_value_view.dart';
import 'package:riverpod_core/core/design_system/widgets/async/empty_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/offline_banner.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton_list.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/banner/app_banner.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';

import '../../../../helpers/fake_connectivity.dart';
import '../display/ds_test_harness.dart';

Widget _view(
  AsyncValue<List<String>> value,
  FakeConnectivity fake, {
  bool isEmpty = false,
  bool isStale = false,
  bool hasPartialError = false,
  DateTime? lastUpdated,
  VoidCallback? onRetry,
  Future<void> Function()? onRefresh,
}) {
  return ProviderScope(
    overrides: [fake.providerOverride],
    child: AsyncValueView<List<String>>(
      value: value,
      isEmpty: isEmpty,
      isStale: isStale,
      hasPartialError: hasPartialError,
      lastUpdated: lastUpdated,
      onRetry: onRetry,
      onRefresh: onRefresh,
      builder: (context, data) =>
          ListView(children: [for (final s in data) ListTile(title: Text(s))]),
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<List<String>> value, {
  FakeConnectivity? connectivity,
  bool isEmpty = false,
  bool isStale = false,
  bool hasPartialError = false,
  DateTime? lastUpdated,
  VoidCallback? onRetry,
  Future<void> Function()? onRefresh,
  String locale = 'en',
  double textScale = 1,
  bool disableAnimations = true,
}) {
  return pumpDs(
    tester,
    _view(
      value,
      connectivity ?? FakeConnectivity(),
      isEmpty: isEmpty,
      isStale: isStale,
      hasPartialError: hasPartialError,
      lastUpdated: lastUpdated,
      onRetry: onRetry,
      onRefresh: onRefresh,
    ),
    locale: locale,
    textScale: textScale,
    disableAnimations: disableAnimations,
  );
}

const _data = AsyncData<List<String>>(['alpha', 'beta']);

void main() {
  testWidgets('loading shows the skeleton', (tester) async {
    await _pump(tester, const AsyncLoading());
    expect(find.byType(SkeletonList), findsOneWidget);
    expect(find.text('alpha'), findsNothing);
  });

  testWidgets('custom loading widget replaces the default skeleton', (
    tester,
  ) async {
    await pumpDs(
      tester,
      ProviderScope(
        overrides: [FakeConnectivity().providerOverride],
        child: AsyncValueView<int>(
          value: const AsyncLoading(),
          loading: const Text('custom'),
          builder: (_, _) => const SizedBox(),
        ),
      ),
    );
    expect(find.text('custom'), findsOneWidget);
    expect(find.byType(SkeletonList), findsNothing);
  });

  testWidgets('empty shows EmptyState, not the builder', (tester) async {
    await _pump(tester, const AsyncData(<String>[]), isEmpty: true);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('error shows localized message and retry works', (tester) async {
    var retries = 0;
    await _pump(
      tester,
      const AsyncError(ServerException(statusCode: 500), StackTrace.empty),
      onRetry: () => retries++,
    );
    expect(find.byType(ErrorState), findsOneWidget);
    expect(
      find.text('Something went wrong on our side. Please try again later.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('error without onRetry hides the retry button', (tester) async {
    await _pump(tester, const AsyncError(UnknownException(), StackTrace.empty));
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('non-AppException errors are mapped, never printed', (
    tester,
  ) async {
    await _pump(tester, AsyncError(StateError('secret'), StackTrace.empty));
    expect(find.textContaining('secret'), findsNothing);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('offline without data shows the offline variant', (tester) async {
    await _pump(
      tester,
      const AsyncError(NetworkException(), StackTrace.empty),
      connectivity: FakeConnectivity(online: false),
      onRetry: () {},
    );
    await tester.pumpAndSettle();
    expect(find.text("You're offline"), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_rounded), findsWidgets);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('going back online retries an error once', (tester) async {
    final fake = FakeConnectivity(online: false);
    var retries = 0;
    await _pump(
      tester,
      const AsyncError(NetworkException(), StackTrace.empty),
      connectivity: fake,
      onRetry: () => retries++,
    );
    await tester.pumpAndSettle();
    fake.setOnline(true);
    await tester.pumpAndSettle();
    expect(retries, 1);
  });

  testWidgets('back online does not retry healthy data', (tester) async {
    final fake = FakeConnectivity(online: false);
    var retries = 0;
    await _pump(tester, _data, connectivity: fake, onRetry: () => retries++);
    await tester.pumpAndSettle();
    fake.setOnline(true);
    await tester.pumpAndSettle();
    expect(retries, 0);
  });

  testWidgets('stale shows data with a last-updated banner', (tester) async {
    await _pump(
      tester,
      _data,
      isStale: true,
      lastUpdated: DateTime(2026, 1, 5, 14, 30),
    );
    expect(find.text('alpha'), findsOneWidget);
    expect(find.textContaining('Last updated'), findsOneWidget);
    expect(find.textContaining('Jan 5, 2026'), findsOneWidget);
  });

  testWidgets('offline with data shows data and the offline banner', (
    tester,
  ) async {
    await _pump(tester, _data, connectivity: FakeConnectivity(online: false));
    await tester.pumpAndSettle();
    expect(find.text('alpha'), findsOneWidget);
    expect(find.text("You're offline. Showing saved data."), findsOneWidget);
  });

  testWidgets('failed reload keeps data and shows the stale banner', (
    tester,
  ) async {
    await _pump(
      tester,
      const AsyncValue<List<String>>.error(
        NetworkException(),
        StackTrace.empty,
        // ignore: invalid_use_of_internal_member
      ).copyWithPrevious(_data),
    );
    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('Showing saved data'), findsOneWidget);
    expect(find.byType(ErrorState), findsNothing);
  });

  testWidgets('partial shows data plus an inline error row with retry', (
    tester,
  ) async {
    var retries = 0;
    await _pump(tester, _data, hasPartialError: true, onRetry: () => retries++);
    expect(find.text('alpha'), findsOneWidget);
    expect(find.byType(AppBanner), findsOneWidget);
    expect(find.text("Some content couldn't be loaded."), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('refreshing keeps data and does not move it', (tester) async {
    await _pump(tester, _data);
    final before = tester.getTopLeft(find.text('alpha'));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await _pump(
      tester,
      // ignore: invalid_use_of_internal_member
      const AsyncLoading<List<String>>().copyWithPrevious(_data),
      disableAnimations: false,
    );
    expect(find.byType(SkeletonList), findsNothing);
    expect(find.text('alpha'), findsOneWidget);
    expect(tester.getTopLeft(find.text('alpha')), before);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('success shows only the content', (tester) async {
    await _pump(tester, _data);
    expect(find.text('alpha'), findsOneWidget);
    expect(find.byType(AppBanner), findsNothing);
    expect(find.byType(EmptyState), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('pull to refresh calls onRefresh', (tester) async {
    var refreshes = 0;
    await _pump(tester, _data, onRefresh: () async => refreshes++);
    await tester.fling(find.text('alpha'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(refreshes, 1);
  });

  testWidgets('pull to refresh works on the empty state too', (tester) async {
    var refreshes = 0;
    await _pump(
      tester,
      const AsyncData(<String>[]),
      isEmpty: true,
      onRefresh: () async => refreshes++,
    );
    await tester.fling(
      find.byType(SingleChildScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(refreshes, 1);
  });

  testWidgets('arabic and text scale 2.0 render without overflow', (
    tester,
  ) async {
    await _pump(
      tester,
      const AsyncError(NetworkException(), StackTrace.empty),
      locale: 'ar',
      textScale: 2,
      onRetry: () {},
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('حاول مرة أخرى'), findsOneWidget);
  });

  testWidgets('OfflineBanner collapses when online and fresh', (tester) async {
    await pumpDs(
      tester,
      ProviderScope(
        overrides: [FakeConnectivity().providerOverride],
        child: const OfflineBanner(),
      ),
    );
    expect(find.byIcon(Icons.wifi_off_rounded), findsNothing);
    expect(find.byIcon(Icons.history_rounded), findsNothing);
  });

  testWidgets('OfflineBanner follows connectivity changes', (tester) async {
    final fake = FakeConnectivity();
    await pumpDs(
      tester,
      ProviderScope(
        overrides: [fake.providerOverride],
        child: const OfflineBanner(),
      ),
    );
    fake.setOnline(false);
    await tester.pumpAndSettle();
    expect(find.text("You're offline"), findsOneWidget);
    fake.setOnline(true);
    await tester.pumpAndSettle();
    expect(find.text("You're offline"), findsNothing);
  });
}
