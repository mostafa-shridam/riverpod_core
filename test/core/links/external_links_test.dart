import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/links/external_links.dart';

import '../../helpers/fake_native_backends.dart';

void main() {
  group('scheme allow-list', () {
    final table = <String, bool>{
      'https://example.com/a?b=1': true,
      'http://example.com': true,
      'HTTPS://EXAMPLE.COM': true,
      '  https://example.com  ': true,
      'javascript:alert(1)': false,
      'file:///etc/passwd': false,
      'intent://scan/#Intent;scheme=zxing;end': false,
      'market://details?id=a.b': false,
      'ftp://example.com': false,
      'data:text/html,hi': false,
      'mailto:a@b.com': false, // not a web url: use openMail
      'example.com': false,
      'https://': false,
      '': false,
    };
    table.forEach((input, allowed) {
      test('openUrl("$input") -> $allowed', () async {
        final backend = FakeLinkBackend();
        final opened = await ExternalLinks(backend).openUrl(input);

        expect(opened, allowed);
        expect(backend.launched.length, allowed ? 1 : 0);
      });
    });

    test('isAllowedLink accepts the four schemes only', () {
      for (final ok in [
        'http://a.b',
        'https://a.b',
        'mailto:a@b.c',
        'tel:+123',
      ]) {
        expect(isAllowedLink(Uri.parse(ok)), isTrue, reason: ok);
      }
      for (final bad in ['sms:123', 'file:///x', 'javascript:1', 'a/b']) {
        expect(isAllowedLink(Uri.parse(bad)), isFalse, reason: bad);
      }
    });
  });

  group('openMail', () {
    test('builds a mailto with an encoded subject and body', () async {
      final backend = FakeLinkBackend();
      final opened = await ExternalLinks(
        backend,
      ).openMail('help@example.com', subject: 'Hi there', body: 'a&b');

      expect(opened, isTrue);
      expect(
        backend.launched.single.toString(),
        'mailto:help%40example.com?subject=Hi%20there&body=a%26b',
      );
    });

    test('works without subject and body', () async {
      final backend = FakeLinkBackend();
      await ExternalLinks(backend).openMail('help@example.com');

      expect(backend.launched.single.scheme, 'mailto');
      expect(backend.launched.single.toString(), isNot(contains('?')));
    });

    test('rejects values that are not an address', () async {
      for (final bad in ['', 'nope', '@x.com', 'a@', 'a b@c.com']) {
        final backend = FakeLinkBackend();
        expect(await ExternalLinks(backend).openMail(bad), isFalse);
        expect(backend.launched, isEmpty, reason: bad);
      }
    });
  });

  group('openPhone', () {
    test('keeps digits and a leading plus', () async {
      final backend = FakeLinkBackend();
      await ExternalLinks(backend).openPhone('+20 (100) 123-4567');

      expect(backend.launched.single.toString(), 'tel:+201001234567');
    });

    test('rejects letters and empty values', () async {
      for (final bad in ['', 'call me', '12;rm', '+', '---']) {
        final backend = FakeLinkBackend();
        expect(await ExternalLinks(backend).openPhone(bad), isFalse);
        expect(backend.launched, isEmpty, reason: bad);
      }
    });
  });

  group('openStore', () {
    test('opens an https store page', () async {
      final backend = FakeLinkBackend();
      final opened = await ExternalLinks(
        backend,
      ).openStore('https://play.google.com/store/apps/details?id=a.b');

      expect(opened, isTrue);
    });

    test('refuses a non-web store url', () async {
      final backend = FakeLinkBackend();

      expect(await ExternalLinks(backend).openStore('market://x'), isFalse);
      expect(backend.launched, isEmpty);
    });
  });

  group('never throws', () {
    test('a platform error is false', () async {
      final backend = FakeLinkBackend(error: StateError('no handler'));

      expect(await ExternalLinks(backend).openUrl('https://a.b'), isFalse);
    });

    test('the platform saying no is false', () async {
      final backend = FakeLinkBackend(result: false);

      expect(await ExternalLinks(backend).openUrl('https://a.b'), isFalse);
      expect(backend.launched.length, 1);
    });
  });
}
