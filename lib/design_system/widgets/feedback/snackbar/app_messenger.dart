import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:riverpod_core/design_system/widgets/feedback/snackbar/app_message.dart';
import 'package:riverpod_core/design_system/widgets/feedback/snackbar/app_toast.dart';

part 'app_messenger.g.dart';

/// Root-level message queue. Shows ONE toast at a time; the rest wait.
///
/// Wire [key] once as `MaterialApp.scaffoldMessengerKey`; after that any
/// code with a `Ref` can call `ref.read(appMessengerProvider).show(...)`
/// without a `BuildContext`. Widgets use `showAppSnackbar`/`showAppToast`.
class AppMessenger {
  /// Attach to `MaterialApp(scaffoldMessengerKey: ...)`.
  final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>(debugLabel: 'AppMessenger');

  final Queue<_Pending> _queue = Queue<_Pending>();
  // A fresh key per toast: reusing one would let Flutter revive the closed
  // toast's State when the next one is inserted in the same frame.
  GlobalKey<AppToastHostState> _hostKey = GlobalKey<AppToastHostState>();
  OverlayEntry? _entry;
  bool _disposed = false;

  /// True while a toast is on screen.
  bool get isShowing => _entry != null;

  /// Number of messages waiting behind the visible one.
  int get queuedCount => _queue.length;

  /// Queues [message]. With [replaceCurrent] the visible toast is dismissed
  /// and everything waiting is dropped, so [message] shows next.
  /// [context] is only a hint to find the overlay when [key] is not wired.
  void show(
    AppMessage message, {
    BuildContext? context,
    bool replaceCurrent = false,
  }) {
    if (_disposed) return;
    if (replaceCurrent) {
      _queue.clear();
      _hostKey.currentState?.dismiss();
    }
    _queue.add(_Pending(message, context));
    _pump();
  }

  /// Dismisses the visible toast; the next one (if any) follows.
  void hideCurrent() => _hostKey.currentState?.dismiss();

  /// Drops everything waiting and dismisses the visible toast.
  void clear() {
    _queue.clear();
    hideCurrent();
  }

  void dispose() {
    _disposed = true;
    _queue.clear();
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }

  void _pump() {
    if (_entry != null || _queue.isEmpty) return;
    final next = _queue.first;
    final overlay = _findOverlay(next.context);
    // No overlay yet (app not built): keep it queued for the next show().
    if (overlay == null) return;
    _queue.removeFirst();
    _hostKey = GlobalKey<AppToastHostState>();
    final hostKey = _hostKey;
    final entry = OverlayEntry(
      builder: (_) => AppToastHost(
        key: hostKey,
        message: next.message,
        onClosed: _onClosed,
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  void _onClosed() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
    if (!_disposed) _pump();
  }

  OverlayState? _findOverlay(BuildContext? hint) {
    if (hint != null && hint.mounted) {
      final fromHint = Overlay.maybeOf(hint, rootOverlay: true);
      if (fromHint != null) return fromHint;
    }
    final root = key.currentContext;
    if (root == null) return null;
    // The messenger sits above the Navigator, so walk down to its Overlay.
    OverlayState? found;
    void visit(Element element) {
      if (found != null) return;
      if (element is StatefulElement && element.state is OverlayState) {
        found = element.state as OverlayState;
        return;
      }
      element.visitChildren(visit);
    }

    (root as Element).visitChildren(visit);
    return found;
  }
}

class _Pending {
  const _Pending(this.message, this.context);

  final AppMessage message;
  final BuildContext? context;
}

/// The app-wide [AppMessenger].
@Riverpod(keepAlive: true)
AppMessenger appMessenger(Ref ref) {
  final messenger = AppMessenger();
  ref.onDispose(messenger.dispose);
  return messenger;
}
