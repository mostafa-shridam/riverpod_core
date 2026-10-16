import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/lists/paginated_list_view.dart';

import '../../../../helpers/helpers.dart';

Widget _list({
  List<int> items = const [0, 1],
  bool hasMore = true,
  bool isLoadingMore = false,
  bool isInitialLoading = false,
  String? pageErrorText,
  VoidCallback? onLoadMore,
  VoidCallback? onRetry,
  Future<void> Function()? onRefresh,
  WidgetBuilder? emptyBuilder,
  WidgetBuilder? loadingBuilder,
}) {
  return SizedBox.expand(
    child: PaginatedListView<int>(
      items: items,
      itemBuilder: (context, item) =>
          SizedBox(height: 100, child: Text('item $item')),
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
      isInitialLoading: isInitialLoading,
      pageErrorText: pageErrorText,
      onLoadMore: onLoadMore ?? () {},
      onRetry: onRetry,
      onRefresh: onRefresh ?? () async {},
      emptyBuilder: emptyBuilder,
      loadingBuilder: loadingBuilder,
    ),
  );
}

List<int> _range(int count) => [for (var i = 0; i < count; i++) i];

void main() {
  group('PaginatedListView load-more trigger', () {
    testWidgets('does not load before 80% of the scroll extent', (
      tester,
    ) async {
      var calls = 0;
      await pumpApp(
        tester,
        _list(items: _range(30), onLoadMore: () => calls++),
      );
      await tester.pump();
      final before = calls;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(calls, before);
    });

    testWidgets('loads the next page at 80% of the scroll extent', (
      tester,
    ) async {
      var calls = 0;
      await pumpApp(
        tester,
        _list(items: _range(30), onLoadMore: () => calls++),
      );
      await tester.pump();
      final before = calls;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(calls, greaterThan(before));
    });

    testWidgets('loads when the content does not fill the screen', (
      tester,
    ) async {
      var calls = 0;
      await pumpApp(tester, _list(items: _range(2), onLoadMore: () => calls++));
      await tester.pumpAndSettle();

      expect(calls, greaterThan(0));
    });

    testWidgets('does not load when there is no next page', (tester) async {
      var calls = 0;
      await pumpApp(
        tester,
        _list(items: _range(2), hasMore: false, onLoadMore: () => calls++),
      );
      await tester.pumpAndSettle();

      expect(calls, 0);
    });
  });

  group('PaginatedListView footer', () {
    testWidgets('shows the loader while the next page loads', (tester) async {
      await pumpApp(tester, _list(isLoadingMore: true, items: _range(2)));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the error text and retry calls onRetry', (tester) async {
      var retries = 0;
      await pumpApp(
        tester,
        _list(
          items: _range(2),
          pageErrorText: 'Network down',
          onRetry: () => retries++,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Network down'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('shows end of list when there are no more pages', (
      tester,
    ) async {
      await pumpApp(tester, _list(items: _range(2), hasMore: false));
      await tester.pumpAndSettle();

      expect(find.text("You've reached the end"), findsOneWidget);
    });

    testWidgets('shows nothing extra while more pages exist', (tester) async {
      await pumpApp(tester, _list(items: _range(2)));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text("You've reached the end"), findsNothing);
    });
  });

  group('PaginatedListView states', () {
    testWidgets('shows the loading builder on the first load', (tester) async {
      await pumpApp(
        tester,
        _list(
          items: const [],
          isInitialLoading: true,
          loadingBuilder: (_) => const Text('first load'),
          emptyBuilder: (_) => const Text('nothing here'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('first load'), findsOneWidget);
      expect(find.text('nothing here'), findsNothing);
    });

    testWidgets('shows the empty builder when there are no items', (
      tester,
    ) async {
      await pumpApp(
        tester,
        _list(
          items: const [],
          hasMore: false,
          emptyBuilder: (_) => const Text('nothing here'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('nothing here'), findsOneWidget);
    });

    testWidgets('pull to refresh calls onRefresh', (tester) async {
      var refreshes = 0;
      await pumpApp(
        tester,
        _list(
          items: _range(20),
          hasMore: false,
          onRefresh: () async => refreshes++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(refreshes, 1);
    });
  });
}
