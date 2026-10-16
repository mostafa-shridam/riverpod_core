/// One page of a paginated endpoint.
///
/// Cursor APIs set [nextCursor]; offset APIs set [nextOffset]. When [hasMore]
/// is true, one of the two must be set so the next request can be built.
class Page<T> {
  const Page({
    required this.items,
    required this.hasMore,
    this.nextCursor,
    this.nextOffset,
  }) : assert(
         !hasMore || nextCursor != null || nextOffset != null,
         'hasMore needs a nextCursor or a nextOffset',
       );

  final List<T> items;
  final bool hasMore;
  final String? nextCursor;
  final int? nextOffset;
}
