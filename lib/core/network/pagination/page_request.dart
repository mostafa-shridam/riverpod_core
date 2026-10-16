/// Which page to fetch: by cursor (opaque server token) or by offset.
sealed class PageRequest {
  const PageRequest({required this.pageSize}) : assert(pageSize > 0);

  final int pageSize;
}

/// Cursor-style request. A null [cursor] asks for the first page.
final class CursorPageRequest extends PageRequest {
  const CursorPageRequest({this.cursor, required super.pageSize});

  final String? cursor;
}

/// Offset-style request, starting at [offset] items.
final class OffsetPageRequest extends PageRequest {
  const OffsetPageRequest({required this.offset, required super.pageSize})
    : assert(offset >= 0);

  final int offset;
}
