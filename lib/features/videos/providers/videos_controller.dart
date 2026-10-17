import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/features/videos/data/videos_repository.dart';
import 'package:riverpod_core/features/videos/providers/videos_state.dart';

part 'videos_controller.g.dart';

/// State and actions of the videos list page.
@riverpod
class VideosController extends _$VideosController {
  // Lives on the notifier, so a reload keeps the search text.
  String _query = '';

  /// Set by [refresh] so the next build reads the network, not the cache.
  bool _freshNext = false;

  @override
  Future<VideosState> build() {
    final fresh = _freshNext;
    _freshNext = false;
    return _load(fresh: fresh);
  }

  Future<VideosState> _load({bool fresh = false}) async {
    final feed = await ref
        .watch(videosRepositoryProvider)
        .fetchFeed(fresh: fresh);
    return VideosState(
      videos: feed.videos,
      loadedAt: DateTime.now(),
      query: _query,
      hasPartialError: feed.hasPartialError,
    );
  }

  /// Filters the loaded videos locally; no request is made.
  void search(String query) {
    _query = query.trim();
    final current = state.value;
    if (current != null) state = AsyncData(current.copyWith(query: _query));
  }

  /// Reloads while keeping the previous data on screen (refreshing; a failure
  /// leaves the old data with the error, which the view shows as stale).
  Future<void> refresh() async {
    _fromScratch = false;
    _freshNext = true;
    ref.invalidateSelf();
    await _settle();
  }

  /// True from a [reload] until the next successful load or [refresh].
  /// Riverpod keeps the previous data inside the loading and error values that
  /// follow, so the page reads this to show the plain loading or error state
  /// instead of the refreshing or stale one.
  bool get dropsPreviousData => _fromScratch;
  bool _fromScratch = false;

  /// Reloads from scratch: the page shows the loading state, not stale data.
  Future<void> reload() async {
    _fromScratch = true;
    // Not invalidateSelf: a rebuild would bring the old data back.
    state = const AsyncLoading<VideosState>();
    state = await AsyncValue.guard(() => _load(fresh: true));
    if (!state.hasError) _fromScratch = false;
  }

  // The error stays in `state` for the UI; callers only need to know when the
  // reload ended.
  Future<void> _settle() async {
    try {
      await future;
    } on Object {
      return;
    }
  }
}
