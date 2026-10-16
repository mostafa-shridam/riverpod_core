import 'package:flutter/material.dart';
import 'package:riverpod_core/core/design_system/responsive/breakpoints.dart';
import 'package:riverpod_core/core/design_system/widgets/lists/pagination_footer.dart';

/// Sliver-based list that loads the next page near the end (80% of the scroll
/// extent by default), supports pull-to-refresh, and shows a footer for the
/// loader, end of list, or a retryable next-page error.
///
/// The caller owns the state: pass the loaded [items] and the flags, and build
/// the first-load and empty states with [loadingBuilder] and [emptyBuilder].
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onRefresh,
    this.isInitialLoading = false,
    this.pageErrorText,
    this.onRetry,
    this.emptyBuilder,
    this.loadingBuilder,
    this.loadMoreThreshold = 0.8,
  }) : assert(loadMoreThreshold > 0 && loadMoreThreshold <= 1);

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Whether the server has another page after the loaded items.
  final bool hasMore;

  /// True while the next page loads. Pass false during a refresh: the
  /// refresh indicator already shows it.
  final bool isLoadingMore;

  /// Called near the end of the list and when the content does not fill the
  /// screen. The notifier ignores calls while a page loads.
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  /// True during the first load, shown with [loadingBuilder] when [items] is empty.
  final bool isInitialLoading;

  /// Localized text of a next-page error; the footer shows it with retry.
  final String? pageErrorText;
  final VoidCallback? onRetry;

  /// Shown instead of the list when [items] is empty and not loading.
  final WidgetBuilder? emptyBuilder;

  /// Shown instead of the list during the first load with no items.
  final WidgetBuilder? loadingBuilder;

  /// Fraction of the scroll extent that triggers [onLoadMore].
  final double loadMoreThreshold;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeLoadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
  }

  @override
  void didUpdateWidget(PaginatedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // New items may leave the list short of the threshold; check again.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_maybeLoadMore)
      ..dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!mounted ||
        !widget.hasMore ||
        widget.isLoadingMore ||
        widget.pageErrorText != null ||
        !_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    final reachedThreshold =
        position.pixels >= position.maxScrollExtent * widget.loadMoreThreshold;
    if (position.maxScrollExtent <= 0 || reachedThreshold) {
      widget.onLoadMore();
    }
  }

  PaginationFooterStatus get _footerStatus {
    if (widget.pageErrorText != null) {
      return PaginationFooterStatus.error;
    }
    if (widget.isLoadingMore) {
      return PaginationFooterStatus.loading;
    }
    if (!widget.hasMore && widget.items.isNotEmpty) {
      return PaginationFooterStatus.end;
    }
    return PaginationFooterStatus.none;
  }

  Widget _emptyContent(BuildContext context) {
    final builder = widget.isInitialLoading
        ? widget.loadingBuilder
        : widget.emptyBuilder;
    return builder?.call(context) ?? const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: CustomScrollView(
            controller: _controller,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (widget.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _emptyContent(context),
                )
              else
                SliverList.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) =>
                      widget.itemBuilder(context, widget.items[index]),
                ),
              SliverToBoxAdapter(
                child: PaginationFooter(
                  status: _footerStatus,
                  errorText: widget.pageErrorText,
                  onRetry: widget.onRetry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
