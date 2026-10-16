import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_screen.g.dart';

/// The native side of screenshot blocking. Tests implement it with a fake.
abstract interface class SecureScreenBackend {
  Future<void> setSecure({required bool secure});
}

/// Android: `FLAG_SECURE` (no screenshots, no recording, hidden in the app
/// switcher). iOS: a cover view while the app is not active. Every other
/// platform, and a missing native handler, is a silent no-op.
class MethodChannelSecureScreenBackend implements SecureScreenBackend {
  const MethodChannelSecureScreenBackend();

  static const channel = MethodChannel('riverpod_core/secure_screen');

  static bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> setSecure({required bool secure}) async {
    if (!_supported) return;
    try {
      await channel.invokeMethod<void>('setSecure', secure);
    } on MissingPluginException {
      // No native handler (tests, unsupported embedder): nothing to protect.
    } on PlatformException {
      // Protection is best effort; never break the screen over it.
    }
  }
}

/// Counts who needs protection, so two screens (or a screen and the app
/// lock) can overlap without one switching it off for the other.
class SecureScreenGate {
  SecureScreenGate(this._backend);

  final SecureScreenBackend _backend;
  int _holders = 0;

  /// Number of active holders; protection is on while it is above zero.
  @visibleForTesting
  int get holders => _holders;

  /// Starts protecting. Pair every call with one [release].
  Future<void> acquire() async {
    _holders++;
    if (_holders == 1) await _backend.setSecure(secure: true);
  }

  /// Stops one holder; the last one switches protection off.
  Future<void> release() async {
    if (_holders == 0) return;
    _holders--;
    if (_holders == 0) await _backend.setSecure(secure: false);
  }
}

/// Backend seam: override in tests with a fake.
@Riverpod(keepAlive: true)
SecureScreenBackend secureScreenBackend(Ref ref) =>
    const MethodChannelSecureScreenBackend();

/// The one [SecureScreenGate] of the app.
@Riverpod(keepAlive: true)
SecureScreenGate secureScreenGate(Ref ref) =>
    SecureScreenGate(ref.watch(secureScreenBackendProvider));

/// Blocks screenshots while it is mounted. Wrap the page that shows
/// sensitive data: `SecureScreen(child: ...)`.
class SecureScreen extends ConsumerStatefulWidget {
  const SecureScreen({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends ConsumerState<SecureScreen> {
  late final SecureScreenGate _gate;

  @override
  void initState() {
    super.initState();
    _gate = ref.read(secureScreenGateProvider);
    unawaited(_gate.acquire());
  }

  @override
  void dispose() {
    unawaited(_gate.release());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
