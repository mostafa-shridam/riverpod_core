import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/network/pagination/page_request.dart';

part 'paginated_state.freezed.dart';

/// State of a paginated list. [pageError] is set when loading the next page
/// failed: the loaded items stay, and [nextRequest] is the request to retry.
@freezed
abstract class PaginatedState<T> with _$PaginatedState<T> {
  const factory PaginatedState({
    required List<T> items,
    required bool hasMore,
    PageRequest? nextRequest,
    AppException? pageError,
  }) = _PaginatedState<T>;
}
