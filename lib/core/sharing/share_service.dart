import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'share_service.g.dart';

/// Platform seam: tests implement it with a fake, so no channel is needed.
abstract interface class ShareBackend {
  /// Shows the system share sheet; true once it was shown.
  Future<bool> shareText(String text, {String? subject});

  Future<bool> shareUri(Uri uri);

  Future<bool> shareFile(String path, {String? text, String? mimeType});
}

/// `share_plus` is imported here and nowhere else.
class SharePlusBackend implements ShareBackend {
  const SharePlusBackend();

  @override
  Future<bool> shareText(String text, {String? subject}) =>
      _share(ShareParams(text: text, subject: subject));

  @override
  Future<bool> shareUri(Uri uri) => _share(ShareParams(uri: uri));

  @override
  Future<bool> shareFile(String path, {String? text, String? mimeType}) =>
      _share(
        ShareParams(
          files: [XFile(path, mimeType: mimeType)],
          text: text,
        ),
      );

  Future<bool> _share(ShareParams params) async {
    // Dismissing the sheet is a normal outcome, not a failure.
    await SharePlus.instance.share(params);
    return true;
  }
}

/// Shares text, links and files through the system share sheet. Methods return
/// whether the sheet was shown and never throw.
class ShareService {
  const ShareService(this._backend);

  final ShareBackend _backend;

  /// Shares plain [text]. Blank text is not shared.
  Future<bool> shareText(String text, {String? subject}) {
    if (text.trim().isEmpty) return Future.value(false);
    return _guard(() => _backend.shareText(text, subject: subject));
  }

  /// Shares a web [link] (absolute http or https).
  Future<bool> shareLink(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      return Future.value(false);
    }
    return _guard(() => _backend.shareUri(uri));
  }

  /// Shares the file at [path], optionally with a [text] caption.
  Future<bool> shareFile(String path, {String? text, String? mimeType}) {
    if (path.trim().isEmpty) return Future.value(false);
    return _guard(
      () => _backend.shareFile(path, text: text, mimeType: mimeType),
    );
  }

  Future<bool> _guard(Future<bool> Function() action) async {
    try {
      return await action();
    } on Object catch (error) {
      debugPrint('share failed: ${error.runtimeType}');
      return false;
    }
  }
}

/// Platform seam: override in tests with a fake.
@Riverpod(keepAlive: true)
ShareBackend shareBackend(Ref ref) => const SharePlusBackend();

/// The one way features open the share sheet.
@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) =>
    ShareService(ref.watch(shareBackendProvider));
