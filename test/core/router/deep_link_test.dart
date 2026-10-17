import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/router/deep_link.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/features/home/presentation/pages/home_page.dart';

void main() {
  group('routeForAppLink maps app links to typed routes', () {
    // link -> expected location (null: ignored).
    const table = <String, String?>{
      'https://example.com/videos/abc': '/videos/abc',
      'https://example.com/items/42': '/items/42',
      'https://example.com/myEvents/7': '/items/7',
      'riverpod-core://videos/abc': '/videos/abc',
      'riverpod-core://items/42': '/items/42',
      // The underscore form an app may write by hand is the same scheme.
      'riverpod_core://videos/abc': '/videos/abc',
      'RIVERPOD_CORE://videos/abc': '/videos/abc',
      'riverpod-core:///videos/abc': null,
      'https://example.com/videos/abc?x=1#top': '/videos/abc',
      'https://EXAMPLE.com/videos/abc': '/videos/abc',
      // Not ours or not mapped.
      'https://other.com/videos/abc': null,
      'https://example.com/unknown/abc': null,
      'https://example.com/videos': null,
      'https://example.com/videos/abc/extra': null,
      'riverpod-core://videos': null,
      'other-app://videos/abc': null,
      'mailto:a@b.com': null,
      'not a link': null,
      'https://example.com/videos/%E0%A4%A': null,
    };

    for (final entry in table.entries) {
      test('${entry.key} -> ${entry.value}', () {
        expect(routeForAppLink(entry.key)?.location, entry.value);
      });
    }

    test('the video links resolve to the video detail route', () {
      for (final link in [
        'https://example.com/videos/abc',
        'riverpod-core://videos/abc',
        'riverpod_core://videos/abc',
      ]) {
        final route = routeForAppLink(link);
        expect(route, isA<VideoDetailRoute>(), reason: link);
        expect((route! as VideoDetailRoute).id, 'abc');
      }
    });
  });

  group('deepLinkRedirect', () {
    test('rewrites a custom-scheme link to the route location', () {
      expect(
        deepLinkRedirect(Uri.parse('riverpod-core://videos/abc')),
        '/videos/abc',
      );
    });

    test('an unmapped custom-scheme link goes home', () {
      expect(
        deepLinkRedirect(Uri.parse('riverpod-core://nope/abc')),
        HomePage.routeName,
      );
    });

    test('https links and in-app locations are left alone', () {
      expect(
        deepLinkRedirect(Uri.parse('https://example.com/videos/abc')),
        isNull,
      );
      expect(deepLinkRedirect(Uri.parse('/videos/abc')), isNull);
    });
  });

  group('routeForDeepLink', () {
    test('the existing routes with an id are mapped', () {
      final item = routeForDeepLink(type: 'items', id: '1');
      final video = routeForDeepLink(type: 'videos', id: '1');
      expect(item, isA<ItemDetailRoute>());
      expect(video, isA<VideoDetailRoute>());
      expect(video, isA<GoRouteData>());
    });
  });
}
