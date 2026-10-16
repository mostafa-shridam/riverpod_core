import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

part 'review_service.g.dart';

/// Settings key of the last time the review prompt was shown. A device
/// setting (no `user.` prefix): it survives logout.
const reviewLastAskedKey = 'review.lastAskedAt';

/// Default gap between two review prompts.
const defaultReviewInterval = Duration(days: 90);

/// Platform seam: tests implement it with a fake, so no channel is needed.
abstract interface class ReviewBackend {
  Future<bool> isAvailable();

  Future<void> requestReview();

  Future<void> openStoreListing({String? appStoreId});
}

/// `in_app_review` is imported here and nowhere else.
class InAppReviewBackend implements ReviewBackend {
  const InAppReviewBackend();

  @override
  Future<bool> isAvailable() => InAppReview.instance.isAvailable();

  @override
  Future<void> requestReview() => InAppReview.instance.requestReview();

  @override
  Future<void> openStoreListing({String? appStoreId}) =>
      InAppReview.instance.openStoreListing(appStoreId: appStoreId);
}

/// Asks for a store review without nagging. Methods return whether something
/// was shown and never throw.
class ReviewService {
  ReviewService({
    required ReviewBackend backend,
    required PrefsStorage prefs,
    required DateTime Function() now,
    this.minInterval = defaultReviewInterval,
    this.appStoreId,
  }) : _backend = backend,
       _prefs = prefs,
       _now = now;

  final ReviewBackend _backend;
  final PrefsStorage _prefs;
  final DateTime Function() _now;

  /// Least time between two prompts.
  final Duration minInterval;

  /// iOS App Store id; Android does not need one.
  final String? appStoreId;

  /// True when the last prompt is older than [minInterval] (or never shown).
  bool get canAsk {
    final last = _lastAsked();
    return last == null || !_now().isBefore(last.add(minInterval));
  }

  /// Call after a good moment (a finished task, a happy streak). Shows the
  /// system review prompt at most once per [minInterval]; when the platform
  /// has no in-app prompt it opens the store listing instead.
  Future<bool> maybeAskForReview() async {
    if (!canAsk) return false;
    try {
      if (await _backend.isAvailable()) {
        await _backend.requestReview();
      } else {
        await _backend.openStoreListing(appStoreId: appStoreId);
      }
    } on Object catch (error) {
      debugPrint('review failed: ${error.runtimeType}');
      return false;
    }
    await _prefs.setStringList(reviewLastAskedKey, [
      _now().toUtc().toIso8601String(),
    ]);
    return true;
  }

  /// The user tapped "Rate the app": open the store listing now. Not
  /// throttled, because the system prompt may silently do nothing.
  Future<bool> openStoreListing() async {
    try {
      await _backend.openStoreListing(appStoreId: appStoreId);
      return true;
    } on Object catch (error) {
      debugPrint('store listing failed: ${error.runtimeType}');
      return false;
    }
  }

  DateTime? _lastAsked() {
    final stored = _prefs.getStringList(reviewLastAskedKey);
    return stored.isEmpty ? null : DateTime.tryParse(stored.first);
  }
}

/// Platform seam: override in tests with a fake.
@Riverpod(keepAlive: true)
ReviewBackend reviewBackend(Ref ref) => const InAppReviewBackend();

/// Clock of the review throttle: override in tests.
@Riverpod(keepAlive: true)
DateTime Function() reviewClock(Ref ref) => DateTime.now;

/// The iOS App Store id used by the store-listing fallback. Null by default:
/// an app overrides it with its own id.
@Riverpod(keepAlive: true)
String? appStoreId(Ref ref) => null;

/// The one way features ask for a review.
@Riverpod(keepAlive: true)
Future<ReviewService> reviewService(Ref ref) async => ReviewService(
  backend: ref.watch(reviewBackendProvider),
  prefs: await ref.watch(prefsStorageProvider.future),
  now: ref.watch(reviewClockProvider),
  appStoreId: ref.watch(appStoreIdProvider),
);
