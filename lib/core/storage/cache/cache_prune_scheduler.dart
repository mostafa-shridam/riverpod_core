import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/cache/cache_pruner.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

part 'cache_prune_scheduler.g.dart';

/// Prunes the cache at startup, after the first frame, and when the app resumes
/// after more than [resumeInterval] (D-038). Runs off the critical path. A
/// failed prune is logged and the next trigger tries again.
class CachePruneScheduler with WidgetsBindingObserver {
  CachePruneScheduler(
    this._pruner,
    this._prefs, {
    Clock? clock,
    AppLogger? logger,
    this.resumeInterval = const Duration(hours: 24),
  }) : _clock = clock ?? DateTime.now,
       _logger = logger ?? const AppLogger(level: LogLevel.warning);

  final CachePruner _pruner;
  final Future<PrefsStorage> _prefs;
  final Clock _clock;
  final AppLogger _logger;
  final Duration resumeInterval;

  /// Listens for resume and schedules the startup prune after the first frame.
  void start() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_prune()));
  }

  void stop() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(pruneIfDue());
    }
  }

  /// Prunes unless the last prune was less than [resumeInterval] ago. Called on
  /// resume; public so the check can be awaited.
  Future<void> pruneIfDue() async {
    try {
      final last = (await _prefs).lastCachePrune;
      if (last != null && _clock().difference(last) < resumeInterval) {
        return;
      }
    } catch (error, stack) {
      _logger.warning(
        'Cache prune check failed',
        error: error,
        stackTrace: stack,
      );
      return;
    }
    await _prune();
  }

  Future<void> _prune() async {
    try {
      await _pruner.prune();
      await (await _prefs).setLastCachePrune(_clock());
    } catch (error, stack) {
      _logger.warning('Cache prune failed', error: error, stackTrace: stack);
    }
  }
}

/// The scheduler for the whole app. Stops listening when the container goes.
@Riverpod(keepAlive: true)
CachePruneScheduler cachePruneScheduler(Ref ref) {
  final scheduler = CachePruneScheduler(
    ref.watch(cachePrunerProvider),
    ref.watch(prefsStorageProvider.future),
    logger: ref.watch(loggerProvider),
  );
  ref.onDispose(scheduler.stop);
  return scheduler;
}
