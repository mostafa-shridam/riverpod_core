import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'external_links.g.dart';

/// The schemes the app may hand to the operating system.
const allowedLinkSchemes = {'http', 'https', 'mailto', 'tel'};

/// Platform seam: tests implement it with a fake, so no channel is needed.
abstract interface class LinkBackend {
  /// True when the platform opened [uri] in another app.
  Future<bool> launch(Uri uri);
}

/// `url_launcher` is imported here and nowhere else in the link code.
class UrlLauncherBackend implements LinkBackend {
  const UrlLauncherBackend();

  @override
  Future<bool> launch(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Opens web pages, mail, phone and store pages outside the app. Every method
/// returns whether something was opened and never throws; an unknown scheme,
/// a malformed value or a platform error is just `false`.
class ExternalLinks {
  const ExternalLinks(this._backend);

  final LinkBackend _backend;

  /// [url] must be an absolute http or https address with a host.
  Future<bool> openUrl(String url) => _open(parseWebUrl(url));

  /// Opens the mail app with a new message to [address].
  Future<bool> openMail(String address, {String? subject, String? body}) =>
      _open(buildMailUri(address, subject: subject, body: body));

  /// Opens the dialer with [number] filled in.
  Future<bool> openPhone(String number) => _open(buildPhoneUri(number));

  /// Opens a store listing. [storeUrl] is the https address of the app page
  /// (for example the `storeUrl` of the remote config).
  Future<bool> openStore(String storeUrl) => openUrl(storeUrl);

  Future<bool> _open(Uri? uri) async {
    if (uri == null || !isAllowedLink(uri)) return false;
    try {
      return await _backend.launch(uri);
    } on Object {
      // A missing handler or a platform error must not crash the caller.
      return false;
    }
  }
}

/// True when [uri] uses one of [allowedLinkSchemes] and, for web links, has a
/// host.
bool isAllowedLink(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  if (!allowedLinkSchemes.contains(scheme)) return false;
  if (scheme == 'http' || scheme == 'https') return uri.host.isNotEmpty;
  return true;
}

/// The http/https [Uri] of [url], or null when it is not one.
@visibleForTesting
Uri? parseWebUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;
  final scheme = uri.scheme.toLowerCase();
  return (scheme == 'http' || scheme == 'https') ? uri : null;
}

/// A `mailto:` [Uri], or null when [address] does not look like an address.
@visibleForTesting
Uri? buildMailUri(String address, {String? subject, String? body}) {
  final trimmed = address.trim();
  final at = trimmed.indexOf('@');
  if (at < 1 || at == trimmed.length - 1 || trimmed.contains(RegExp(r'\s'))) {
    return null;
  }
  // Built by hand: `Uri(queryParameters:)` writes spaces as `+`, which mail
  // apps show literally.
  final query = [
    if (subject != null && subject.isNotEmpty)
      'subject=${Uri.encodeComponent(subject)}',
    if (body != null && body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
  ].join('&');
  return Uri.parse(
    'mailto:${Uri.encodeComponent(trimmed)}${query.isEmpty ? '' : '?$query'}',
  );
}

/// A `tel:` [Uri], or null when [number] has no digits or other characters
/// than digits, `+`, spaces, dashes, dots and brackets. Separators are
/// dropped; a leading `+` is kept.
@visibleForTesting
Uri? buildPhoneUri(String number) {
  final trimmed = number.trim();
  if (!RegExp(r'^[0-9+\-\s().]+$').hasMatch(trimmed)) return null;
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return Uri.parse('tel:${trimmed.startsWith('+') ? '+' : ''}$digits');
}

/// Platform seam: override in tests with a fake.
@Riverpod(keepAlive: true)
LinkBackend linkBackend(Ref ref) => const UrlLauncherBackend();

/// The one way features open external links.
@Riverpod(keepAlive: true)
ExternalLinks externalLinks(Ref ref) =>
    ExternalLinks(ref.watch(linkBackendProvider));
