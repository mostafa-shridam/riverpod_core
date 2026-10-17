import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_backend.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';

import 'fake_video_backend.dart';

void main() {
  test('the default factory is the video_player one', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(videoBackendFactoryProvider),
      same(createVideoPlayerBackend),
    );
  });

  test('an override replaces the backend every player gets', () {
    final fakes = FakeVideoFactory();
    final container = ProviderContainer(
      overrides: [videoBackendFactoryProvider.overrideWithValue(fakes.call)],
    );
    addTearDown(container.dispose);

    final backend = container.read(videoBackendFactoryProvider)(
      const AppVideoSource.network('https://example.test/a.mp4'),
    );

    expect(backend, same(fakes.last));
    expect(fakes.created, hasLength(1));
  });
}
