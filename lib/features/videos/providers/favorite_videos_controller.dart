import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/features/videos/data/videos_repository.dart';

part 'favorite_videos_controller.g.dart';

/// Ids of the favorite videos, persisted through the repository (prefs).
@riverpod
class FavoriteVideosController extends _$FavoriteVideosController {
  @override
  Future<Set<String>> build() =>
      ref.watch(videosRepositoryProvider).favoriteIds();

  /// Adds [id] to the favorites, or removes it when already there.
  Future<void> toggle(String id) async {
    state = await AsyncValue.guard(
      () => ref.read(videosRepositoryProvider).toggleFavorite(id),
    );
  }
}
