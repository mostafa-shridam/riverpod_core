import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/core/network/pagination/page.dart';
import 'package:riverpod_core/core/network/pagination/page_request.dart';
import 'package:riverpod_core/core/network/pagination/paginated_state.dart';

/// Base notifier for paginated lists (NETWORKING.md, C-14).
///
/// A concrete `@riverpod` notifier implements [build] as `firstPage()` and
/// [fetchPage]. The base handles loading, [loadMore], [refresh], de-duplication
/// by [idOf], and dropping results that arrive after a refresh or dispose.
abstract class PaginatedNotifier<T> extends AsyncNotifier<PaginatedState<T>> {
  /// Fetches one page. Throw an [AppException], or any error (it is mapped).
  Future<Page<T>> fetchPage(PageRequest request);

  /// Page size for every request.
  int get pageSize => 20;

  /// Request for the first page. Override for cursor APIs.
  PageRequest get firstRequest =>
      OffsetPageRequest(offset: 0, pageSize: pageSize);

  /// Identity used to drop duplicate items across pages.
  Object? idOf(T item) => item;

  var _disposed = false;
  var _generation = 0;
  var _loadingMore = false;
  var _lastFailureWasRefresh = false;

  /// Loads the first page. Call it from `build()` of the concrete notifier.
  Future<PaginatedState<T>> firstPage() async {
    _disposed = false;
    _generation++;
    _loadingMore = false;
    ref.onDispose(() => _disposed = true);
    final page = await _load(firstRequest);
    return PaginatedState(
      items: _merge(const [], page.items),
      hasMore: page.hasMore,
      nextRequest: _nextRequest(page),
    );
  }

  /// Loads the next page. Ignored while a load or refresh is running, and when
  /// there is no next page. After a failure, calling it again retries the page.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        state.isLoading ||
        _loadingMore ||
        !current.hasMore ||
        current.nextRequest == null) {
      return;
    }
    _loadingMore = true;
    final generation = _generation;
    try {
      final page = await _load(current.nextRequest!);
      if (!_isCurrent(generation)) return;
      final latest = state.value ?? current;
      _lastFailureWasRefresh = false;
      state = AsyncData(
        latest.copyWith(
          items: _merge(latest.items, page.items),
          hasMore: page.hasMore,
          nextRequest: _nextRequest(page),
          pageError: null,
        ),
      );
    } on AppException catch (error) {
      if (!_isCurrent(generation)) return;
      final latest = state.value ?? current;
      _lastFailureWasRefresh = false;
      state = AsyncData(latest.copyWith(pageError: error));
    } finally {
      _loadingMore = false;
    }
  }

  /// Reloads the first page. Keeps the loaded items while it runs; if it fails
  /// with items on screen, they stay and [PaginatedState.pageError] is set.
  Future<void> refresh() async {
    final generation = ++_generation;
    _loadingMore = false;
    final previous = state.value;
    // Riverpod keeps the previous value while loading, so the items stay on screen.
    state = AsyncLoading<PaginatedState<T>>();
    try {
      final page = await _load(firstRequest);
      if (!_isCurrent(generation)) return;
      _lastFailureWasRefresh = false;
      state = AsyncData(
        PaginatedState(
          items: _merge(const [], page.items),
          hasMore: page.hasMore,
          nextRequest: _nextRequest(page),
        ),
      );
    } on AppException catch (error) {
      if (!_isCurrent(generation)) return;
      _lastFailureWasRefresh = true;
      state = previous == null
          ? AsyncError<PaginatedState<T>>(error, StackTrace.current)
          : AsyncData(previous.copyWith(pageError: error));
    }
  }

  /// Retries whatever failed last: a refresh, or the next page.
  Future<void> retry() => _lastFailureWasRefresh ? refresh() : loadMore();

  Future<Page<T>> _load(PageRequest request) async {
    try {
      return await fetchPage(request);
    } catch (error, stack) {
      throw mapError(error, stack);
    }
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  PageRequest? _nextRequest(Page<T> page) {
    if (!page.hasMore) {
      return null;
    }
    if (page.nextCursor != null) {
      return CursorPageRequest(cursor: page.nextCursor, pageSize: pageSize);
    }
    return OffsetPageRequest(offset: page.nextOffset!, pageSize: pageSize);
  }

  List<T> _merge(List<T> existing, List<T> incoming) {
    final seen = {for (final item in existing) idOf(item)};
    final merged = [...existing];
    for (final item in incoming) {
      if (seen.add(idOf(item))) {
        merged.add(item);
      }
    }
    return merged;
  }
}
