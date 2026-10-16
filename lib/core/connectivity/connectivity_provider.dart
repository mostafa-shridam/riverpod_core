import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:riverpod_core/core/connectivity/connectivity_service.dart';

part 'connectivity_provider.g.dart';

/// Online/offline status: the current value first, then each change. Repeated
/// identical statuses are dropped. While the first check runs the value is
/// loading, which readers should treat as online.
@Riverpod(keepAlive: true)
Stream<ConnectivityStatus> connectivity(Ref ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  var last = await service.check();
  yield last;
  await for (final next in service.changes) {
    if (next == last) continue;
    last = next;
    yield next;
  }
}

/// Emits an incrementing counter each time the device goes from offline back
/// to online. A counter (not `void`) because providers drop equal values, so
/// a second reconnect would otherwise be invisible to listeners.
@Riverpod(keepAlive: true)
Stream<int> backOnline(Ref ref) {
  final controller = StreamController<int>();
  ref.onDispose(controller.close);
  var count = 0;
  ref.listen(connectivityProvider, (previous, next) {
    if (previous?.value == ConnectivityStatus.offline &&
        next.value == ConnectivityStatus.online) {
      controller.add(++count);
    }
  });
  return controller.stream;
}
