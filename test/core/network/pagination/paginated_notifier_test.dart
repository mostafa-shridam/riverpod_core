import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/network/pagination/page.dart';
import 'package:riverpod_core/core/network/pagination/page_request.dart';
import 'package:riverpod_core/core/network/pagination/paginated_notifier.dart';
import 'package:riverpod_core/core/network/pagination/paginated_state.dart';

import '../../../helpers/helpers.dart';

/// Records every request and answers with [handler], set per test.
class FakePager {
  final requests = <PageRequest>[];
  Future<Page<int>> Function(PageRequest request)? handler;

  Future<Page<int>> fetch(PageRequest request) {
    requests.add(request);
    return handler!(request);
  }
}

final fakePagerProvider = Provider<FakePager>((ref) => FakePager());

/// Offset pages over `0..total-1`, sized by the request.
Page<int> offsetPage(OffsetPageRequest request, {int total = 6}) {
  final end = request.offset + request.pageSize;
  final items = [for (var i = request.offset; i < end && i < total; i++) i];
  final hasMore = end < total;
  return Page(items: items, hasMore: hasMore, nextOffset: hasMore ? end : null);
}

class Numbers extends PaginatedNotifier<int> {
  @override
  Future<PaginatedState<int>> build() => firstPage();

  @override
  int get pageSize => 2;

  @override
  Future<Page<int>> fetchPage(PageRequest request) =>
      ref.read(fakePagerProvider).fetch(request);
}

class CursorNumbers extends PaginatedNotifier<int> {
  @override
  Future<PaginatedState<int>> build() => firstPage();

  @override
  PageRequest get firstRequest => const CursorPageRequest(pageSize: 2);

  @override
  Future<Page<int>> fetchPage(PageRequest request) =>
      ref.read(fakePagerProvider).fetch(request);
}

// Written by hand: build.yaml generates code for lib/ only.
final numbersProvider = AsyncNotifierProvider<Numbers, PaginatedState<int>>(
  Numbers.new,
);
final cursorNumbersProvider =
    AsyncNotifierProvider<CursorNumbers, PaginatedState<int>>(
      CursorNumbers.new,
    );

void main() {
  late FakePager pager;
  late ProviderContainer container;

  setUp(() {
    pager = FakePager()
      ..handler = (request) async => offsetPage(request as OffsetPageRequest);
    container = createContainer(
      overrides: [fakePagerProvider.overrideWithValue(pager)],
    );
  });

  Numbers numbers() => container.read(numbersProvider.notifier);

  // Riverpod retries a failing build by default; these tests expect the error at once.
  ProviderContainer noRetryContainer() {
    final local = ProviderContainer(
      retry: (_, _) => null,
      overrides: [fakePagerProvider.overrideWithValue(pager)],
    );
    addTearDown(local.dispose);
    return local;
  }

  group('PaginatedNotifier', () {
    test('build loads the first page with the first request', () async {
      final state = await container.read(numbersProvider.future);

      expect(state.items, [0, 1]);
      expect(state.hasMore, isTrue);
      expect(state.nextRequest, isA<OffsetPageRequest>());
      expect((state.nextRequest! as OffsetPageRequest).offset, 2);
      expect(pager.requests.single, isA<OffsetPageRequest>());
    });

    test('loadMore appends the next page', () async {
      await container.read(numbersProvider.future);

      await numbers().loadMore();

      expect(container.read(numbersProvider).requireValue.items, [0, 1, 2, 3]);
      expect(pager.requests, hasLength(2));
    });

    test('cursor pages pass the cursor from one page to the next', () async {
      pager.handler = (request) async {
        final cursor = (request as CursorPageRequest).cursor;
        return cursor == null
            ? const Page(items: [1, 2], hasMore: true, nextCursor: 'c1')
            : const Page(items: [3, 4], hasMore: false);
      };

      await container.read(cursorNumbersProvider.future);
      await container.read(cursorNumbersProvider.notifier).loadMore();

      expect(container.read(cursorNumbersProvider).requireValue.items, [
        1,
        2,
        3,
        4,
      ]);
      expect(pager.requests.map((r) => (r as CursorPageRequest).cursor), [
        null,
        'c1',
      ]);
    });

    test('items already loaded are dropped from the next page', () async {
      pager.handler = (request) async {
        final offset = (request as OffsetPageRequest).offset;
        return offset == 0
            ? const Page(items: [0, 1], hasMore: true, nextOffset: 2)
            : const Page(items: [1, 2], hasMore: false);
      };

      await container.read(numbersProvider.future);
      await numbers().loadMore();

      expect(container.read(numbersProvider).requireValue.items, [0, 1, 2]);
    });

    test('concurrent loadMore calls fetch the next page once', () async {
      await container.read(numbersProvider.future);
      final gate = Completer<Page<int>>();
      pager.handler = (request) => gate.future;

      final first = numbers().loadMore();
      final second = numbers().loadMore();
      expect(pager.requests, hasLength(2));

      gate.complete(const Page(items: [2, 3], hasMore: false));
      await Future.wait([first, second]);
      expect(pager.requests, hasLength(2));
    });

    test('loadMore does nothing when there is no next page', () async {
      pager.handler = (request) async => const Page(items: [0], hasMore: false);
      await container.read(numbersProvider.future);

      await numbers().loadMore();

      expect(pager.requests, hasLength(1));
    });

    test('a failed next page keeps the items and retry loads it', () async {
      await container.read(numbersProvider.future);
      var fail = true;
      pager.handler = (request) async {
        if (fail) {
          throw const NetworkException();
        }
        return offsetPage(request as OffsetPageRequest);
      };

      await numbers().loadMore();

      final failed = container.read(numbersProvider).requireValue;
      expect(failed.items, [0, 1]);
      expect(failed.pageError, isA<NetworkException>());

      fail = false;
      await numbers().retry();

      final recovered = container.read(numbersProvider).requireValue;
      expect(recovered.items, [0, 1, 2, 3]);
      expect(recovered.pageError, isNull);
    });

    test('refresh keeps the items on screen while it reloads', () async {
      await container.read(numbersProvider.future);
      await numbers().loadMore();
      final gate = Completer<Page<int>>();
      pager.handler = (request) => gate.future;

      final refreshing = numbers().refresh();
      final during = container.read(numbersProvider);
      expect(during.isLoading, isTrue);
      expect(during.requireValue.items, [0, 1, 2, 3]);

      gate.complete(const Page(items: [9, 8], hasMore: false));
      await refreshing;
      expect(container.read(numbersProvider).requireValue.items, [9, 8]);
    });

    test('a failed refresh keeps the items and retry refreshes', () async {
      await container.read(numbersProvider.future);
      pager.handler = (request) async => throw const NetworkException();

      await numbers().refresh();

      final failed = container.read(numbersProvider).requireValue;
      expect(failed.items, [0, 1]);
      expect(failed.pageError, isA<NetworkException>());

      pager.handler = (request) async => const Page(items: [7], hasMore: false);
      await numbers().retry();

      expect(container.read(numbersProvider).requireValue.items, [7]);
      expect(pager.requests.last, isA<OffsetPageRequest>());
    });

    test('a failed first page is an AppException error state', () async {
      pager.handler = (request) async => throw const NetworkException();

      await expectLater(
        noRetryContainer().read(numbersProvider.future),
        throwsA(isA<NetworkException>()),
      );
    });

    test('unknown errors are mapped to UnknownException', () async {
      pager.handler = (request) async => throw StateError('boom');

      await expectLater(
        noRetryContainer().read(numbersProvider.future),
        throwsA(isA<UnknownException>()),
      );
    });

    test('a result that arrives after dispose is dropped', () async {
      final local = ProviderContainer(
        overrides: [fakePagerProvider.overrideWithValue(pager)],
      );
      await local.read(numbersProvider.future);
      final gate = Completer<Page<int>>();
      pager.handler = (request) => gate.future;
      final pending = local.read(numbersProvider.notifier).loadMore();

      local.dispose();
      gate.complete(const Page(items: [2, 3], hasMore: false));

      await expectLater(pending, completes);
    });
  });
}
