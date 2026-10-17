import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/features/home/presentation/pages/home_page.dart';

/// Host of the https app links. A placeholder: an app sets its own domain here
/// AND in AndroidManifest.xml and Runner.entitlements (`tool/rename_app.dart
/// --host` does all three). See ai-docs/DEEP_LINKS.md.
const deepLinkHost = 'example.com';

/// Custom URL scheme of the app, `<dart package with - for _>://type/id`. It
/// must be a valid URI scheme (no underscore), so it is the package name with
/// hyphens. Keep it equal to AndroidManifest.xml and Info.plist.
const deepLinkScheme = 'riverpod-core';

final _linkPattern = RegExp(
  r'^([A-Za-z][A-Za-z0-9+.\-_]*)://([^/?#]*)([^?#]*)',
);

String _normalizeScheme(String scheme) =>
    scheme.toLowerCase().replaceAll('_', '-');

/// Maps an app link to a typed route; null when it is not ours or not mapped.
///
/// `https://<deepLinkHost>/<type>/<id>` and `<deepLinkScheme>://<type>/<id>`
/// resolve through `routeForDeepLink`. The link is read as text on purpose:
/// `Uri.parse` rejects a scheme with an underscore (`riverpod_core://...`),
/// which an app may have written by hand. The underscore form is accepted as
/// the same scheme.
GoRouteData? routeForAppLink(String link) {
  final match = _linkPattern.firstMatch(link.trim());
  if (match == null) {
    return null;
  }
  final scheme = _normalizeScheme(match.group(1)!);
  final authority = match.group(2)!;
  final segments = [
    for (final part in match.group(3)!.split('/'))
      if (part.isNotEmpty) part,
  ];

  final List<String> parts;
  if (scheme == 'https' || scheme == 'http') {
    if (authority.toLowerCase() != deepLinkHost) {
      return null;
    }
    parts = segments;
  } else if (scheme == deepLinkScheme && authority.isNotEmpty) {
    // `scheme://videos/abc`: the type is parsed as the host.
    parts = [authority, ...segments];
  } else {
    return null;
  }
  if (parts.length != 2) {
    return null;
  }
  try {
    return routeForDeepLink(
      type: Uri.decodeComponent(parts[0]),
      id: Uri.decodeComponent(parts[1]),
    );
  } on FormatException {
    return null;
  } on ArgumentError {
    return null;
  }
}

/// Router redirect for the custom scheme. go_router matches the path only, so
/// `riverpod-core://videos/abc` (path `/abc`) is rewritten to the typed route
/// location. An unmapped custom-scheme link goes home. https links need no
/// rewrite: their path already is the route path. Null for every other URI.
String? deepLinkRedirect(Uri uri) {
  if (uri.scheme != deepLinkScheme) {
    return null;
  }
  return routeForAppLink(uri.toString())?.location ?? HomePage.routeName;
}
