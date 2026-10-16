import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_core/core/connectivity/connectivity_provider.dart';
import 'package:riverpod_core/core/connectivity/connectivity_service.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_motion.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_strings.dart';
import 'package:riverpod_core/core/design_system/widgets/async/empty_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/offline_banner.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton_list.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/banner/app_banner.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';

/// Renders an [AsyncValue] in the 8 data states of DESIGN_SYSTEM.md.
///
/// | state | when |
/// |---|---|
/// | loading | no data yet and loading: [loading] or a `SkeletonList` |
/// | empty | data and [isEmpty]: [empty] or the default `EmptyState` |
/// | error | no data and failed: `ErrorState` with [onRetry] |
/// | offline | as error, while `connectivityProvider` says offline |
/// | stale | data and ([isStale], offline, or a failed reload): banner |
/// | partial | data and [hasPartialError]: inline error row + retry |
/// | refreshing | data and loading: thin progress line, no layout jump |
/// | success | data: [builder] |
///
/// Needs a bounded height (a page body): banners sit above the content, which
/// fills the rest. For pull-to-refresh pass [onRefresh] and make the content
/// of [builder] scrollable; empty/error states scroll by themselves. When the
/// device comes back online while the view shows an error or stale data,
/// [onRetry] runs once.
class AsyncValueView<T> extends ConsumerStatefulWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.builder,
    this.isEmpty = false,
    this.isStale = false,
    this.hasPartialError = false,
    this.lastUpdated,
    this.onRetry,
    this.onRefresh,
    this.onPartialRetry,
    this.partialErrorMessage,
    this.loading,
    this.empty,
  });

  final AsyncValue<T> value;

  /// Builds the content from data. Not called for the empty state.
  final Widget Function(BuildContext context, T data) builder;

  /// The data is valid but has zero items.
  final bool isEmpty;

  /// The data comes from a cache that may be outdated.
  final bool isStale;

  /// Some parts of the data failed to load; the rest is shown.
  final bool hasPartialError;

  /// When the shown data was fetched, for the stale banner.
  final DateTime? lastUpdated;

  /// Retry after a failure and on reconnect. Without it no retry shows.
  final VoidCallback? onRetry;

  /// Enables pull-to-refresh; completes when the reload is done.
  final Future<void> Function()? onRefresh;

  /// Retry for the failed part; defaults to [onRetry].
  final VoidCallback? onPartialRetry;

  /// Text of the partial-error row; defaults to the localized one.
  final String? partialErrorMessage;

  /// Custom loading placeholder (usually a `Skeleton` of the real layout).
  final Widget? loading;

  /// Custom empty state; defaults to a generic `EmptyState`.
  final Widget? empty;

  @override
  ConsumerState<AsyncValueView<T>> createState() => _AsyncValueViewState<T>();
}

enum _View { loading, empty, error, content }

class _AsyncValueViewState<T> extends ConsumerState<AsyncValueView<T>> {
  // True while a pull-to-refresh runs: its own indicator replaces the line.
  bool _pulling = false;

  Future<void> _refresh() async {
    setState(() => _pulling = true);
    try {
      await widget.onRefresh!();
    } finally {
      if (mounted) setState(() => _pulling = false);
    }
  }

  bool get _needsRetry => !widget.value.isLoading && widget.value.hasError;

  @override
  Widget build(BuildContext context) {
    ref.listen(backOnlineProvider, (_, next) {
      if (next.hasValue && (_needsRetry || widget.isStale)) {
        widget.onRetry?.call();
      }
    });
    final offline =
        ref.watch(connectivityProvider).value == ConnectivityStatus.offline;
    final value = widget.value;
    final hasData = value.hasValue;
    final tokens = context.tokens;

    final view = !hasData
        ? (value.isLoading ? _View.loading : _View.error)
        : (widget.isEmpty ? _View.empty : _View.content);

    final failedReload = hasData && !value.isLoading && value.hasError;
    final showBanner =
        view == _View.content && (widget.isStale || offline || failedReload);
    final showPartial = view == _View.content && widget.hasPartialError;
    final refreshing = hasData && value.isLoading && !_pulling;

    Widget body = switch (view) {
      _View.loading => KeyedSubtree(
        key: const ValueKey('loading'),
        child: widget.loading ?? const SkeletonList(),
      ),
      _View.empty => KeyedSubtree(
        key: const ValueKey('empty'),
        child: _scrollable(widget.empty ?? const EmptyState()),
      ),
      _View.error => KeyedSubtree(
        key: const ValueKey('error'),
        child: _scrollable(_errorState(value, offline)),
      ),
      _View.content => KeyedSubtree(
        key: const ValueKey('content'),
        child: widget.builder(context, value.requireValue),
      ),
    };

    if (widget.onRefresh != null && view != _View.loading) {
      body = RefreshIndicator(onRefresh: _refresh, child: body);
    }

    final duration = motionDuration(context, tokens.durations.normal);
    return Column(
      children: [
        OfflineBanner(
          isOffline: showBanner && offline,
          isStale: showBanner,
          lastUpdated: showBanner ? widget.lastUpdated : null,
        ),
        AnimatedSize(
          duration: duration,
          curve: tokens.durations.standardCurve,
          alignment: AlignmentDirectional.topStart,
          child: showPartial
              ? Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    tokens.spacing.lg,
                    tokens.spacing.sm,
                    tokens.spacing.lg,
                    0,
                  ),
                  child: AppBanner(
                    type: AppStatusType.error,
                    message:
                        widget.partialErrorMessage ?? asyncPartialErrorKey.tr(),
                    actionLabel: asyncRetryKey.tr(),
                    onAction: widget.onPartialRetry ?? widget.onRetry,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: duration,
                  layoutBuilder: (current, previous) => Stack(
                    fit: StackFit.expand,
                    children: [...previous, ?current],
                  ),
                  child: body,
                ),
              ),
              // Overlaid, not inserted: starting a reload never moves content.
              PositionedDirectional(
                top: 0,
                start: 0,
                end: 0,
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: motionDuration(context, tokens.durations.fast),
                    child: refreshing
                        ? LinearProgressIndicator(
                            minHeight: tokens.sizes.spinnerStroke * 2,
                            backgroundColor: Colors.transparent,
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorState(AsyncValue<T> value, bool offline) {
    final error = value.error;
    final exception = error == null
        ? null
        : (error is AppException
              ? error
              : mapError(error, value.stackTrace ?? StackTrace.empty));
    return ErrorState(
      exception: exception,
      isOffline: offline,
      onRetry: widget.onRetry,
    );
  }

  /// Lets short states be pulled to refresh and survive large text scales.
  Widget _scrollable(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.hasBoundedHeight ? constraints.maxHeight : 0,
          ),
          child: child,
        ),
      ),
    );
  }
}
