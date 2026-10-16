import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/sharing/share_service.dart';

import '../../helpers/fake_native_backends.dart';
import '../../helpers/helpers.dart';

void main() {
  test('shareText sends the text and subject', () async {
    final backend = FakeShareBackend();

    final shown = await ShareService(
      backend,
    ).shareText('hello', subject: 'Greeting');

    expect(shown, isTrue);
    expect(backend.texts, ['hello']);
    expect(backend.lastSubject, 'Greeting');
  });

  test('blank text is not shared', () async {
    final backend = FakeShareBackend();

    expect(await ShareService(backend).shareText('   '), isFalse);
    expect(backend.texts, isEmpty);
  });

  test('shareLink accepts web links and rejects the rest', () async {
    final backend = FakeShareBackend();
    final service = ShareService(backend);

    expect(await service.shareLink('https://example.com/p?id=1'), isTrue);
    expect(backend.uris.single.host, 'example.com');
    for (final bad in [
      'javascript:1',
      'file:///x',
      'example.com',
      '',
      'https://',
    ]) {
      expect(await service.shareLink(bad), isFalse, reason: bad);
    }
    expect(backend.uris.length, 1);
  });

  test('shareFile passes path, caption and mime type', () async {
    final backend = FakeShareBackend();

    final shown = await ShareService(
      backend,
    ).shareFile('/tmp/a.pdf', text: 'Report', mimeType: 'application/pdf');

    expect(shown, isTrue);
    expect(backend.files, ['/tmp/a.pdf']);
    expect(backend.lastCaption, 'Report');
    expect(backend.lastMimeType, 'application/pdf');
    expect(await ShareService(backend).shareFile(''), isFalse);
  });

  test('a platform error is false, never thrown', () async {
    final service = ShareService(FakeShareBackend(error: StateError('x')));

    expect(await service.shareText('hi'), isFalse);
    expect(await service.shareLink('https://a.b'), isFalse);
    expect(await service.shareFile('/tmp/a'), isFalse);
  });

  test('shareServiceProvider uses the overridden backend', () async {
    final backend = FakeShareBackend();
    final container = createContainer(
      overrides: [shareBackendProvider.overrideWithValue(backend)],
    );

    await container.read(shareServiceProvider).shareText('x');

    expect(backend.texts, ['x']);
    expect(container.read(shareServiceProvider), isA<ShareService>());
  });
}
