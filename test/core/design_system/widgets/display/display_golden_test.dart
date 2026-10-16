import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_accordion.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_avatar.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_badge.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_card.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_chip.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_divider.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_image.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_section_header.dart';

import 'ds_test_harness.dart';

/// Image from a pre-built gradient: deterministic, no network or assets.
class _GradientImage extends ImageProvider<_GradientImage> {
  const _GradientImage(this.image);

  final ui.Image image;

  @override
  Future<_GradientImage> obtainKey(ImageConfiguration configuration) =>
      Future.value(this);

  @override
  ImageStreamCompleter loadImage(
    _GradientImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image)));
}

class _PendingImage extends ImageProvider<_PendingImage> {
  @override
  Future<_PendingImage> obtainKey(ImageConfiguration configuration) =>
      Future.value(this);

  @override
  ImageStreamCompleter loadImage(
    _PendingImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(Completer<ImageInfo>().future);
}

class _FailingImage extends ImageProvider<_FailingImage> {
  @override
  Future<_FailingImage> obtainKey(ImageConfiguration configuration) =>
      Future.value(this);

  @override
  ImageStreamCompleter loadImage(
    _FailingImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    Future<ImageInfo>.error(Exception('golden: failing image')),
  );
}

Future<ui.Image> _gradient(WidgetTester tester) async {
  final image = await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(160, 90);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          [const Color(0xFF4A6FA5), const Color(0xFFE8A87C)],
        ),
    );
    return recorder.endRecording().toImage(160, 90);
  });
  return image!;
}

Widget _gallery(ui.Image image) {
  Widget gap() => const SizedBox(height: 12);
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionHeader(
            title: 'Section title',
            subtitle: 'Short description',
            trailing: Text('See all'),
            padding: EdgeInsets.zero,
          ),
          gap(),
          const AppCard(child: Text('Filled card')),
          gap(),
          const AppCard(
            variant: AppCardVariant.outlined,
            child: Text('Outlined card'),
          ),
          gap(),
          AppCard(
            variant: AppCardVariant.elevated,
            onTap: () {},
            child: const Text('Elevated, tappable card'),
          ),
          gap(),
          const AppListTile(
            leading: Icon(Icons.person_outline),
            title: Text('List tile'),
            subtitle: Text('With subtitle and chevron'),
            showChevron: true,
          ),
          const AppListTile(
            leading: Icon(Icons.star_outline),
            title: Text('Selected tile'),
            selected: true,
          ),
          const AppListTile(title: Text('Disabled tile'), enabled: false),
          const AppDivider(inset: AppDividerInset.start),
          const AppDivider(label: 'or'),
          gap(),
          Row(
            children: [
              for (final s in AppAvatarSize.values) ...[
                AppAvatar(name: 'Ada Byron', size: s),
                const SizedBox(width: 8),
              ],
            ],
          ),
          gap(),
          const Row(
            children: [
              AppAvatar(name: 'Sam Lee', status: AppAvatarStatus.online),
              SizedBox(width: 16),
              AppAvatar(name: 'Noor Ali', status: AppAvatarStatus.busy),
              SizedBox(width: 16),
              AppAvatar(status: AppAvatarStatus.away),
              SizedBox(width: 16),
              AppAvatar(name: 'محمد علي', status: AppAvatarStatus.offline),
              SizedBox(width: 16),
              AppBadge(count: 7, child: Icon(Icons.mail_outline)),
              SizedBox(width: 16),
              AppBadge(count: 150, child: Icon(Icons.notifications_none)),
              SizedBox(width: 16),
              AppBadge.dot(child: Icon(Icons.chat_bubble_outline)),
            ],
          ),
          gap(),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(label: 'Neutral', icon: Icons.tag),
              AppChip(label: 'Primary', tone: AppChipTone.primary),
              AppChip(label: 'Success', tone: AppChipTone.success),
              AppChip(label: 'Warning', tone: AppChipTone.warning),
              AppChip(label: 'Error', tone: AppChipTone.error),
              AppChip(label: 'Info', tone: AppChipTone.info),
            ],
          ),
          gap(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(label: 'Filter off', onSelected: (_) {}),
              AppChip(
                label: 'Filter on',
                selected: true,
                tone: AppChipTone.primary,
                onSelected: (_) {},
              ),
              AppChip(label: 'Removable', onDeleted: () {}),
            ],
          ),
          gap(),
          Row(
            children: [
              Expanded(
                child: AppImage.provider(
                  _GradientImage(image),
                  height: 80,
                  rounded: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppImage.provider(
                  _PendingImage(),
                  height: 80,
                  rounded: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppImage.provider(
                  _FailingImage(),
                  height: 80,
                  rounded: true,
                ),
              ),
            ],
          ),
          gap(),
          const AppAccordion(
            title: 'Accordion open',
            subtitle: 'Animated content',
            leading: Icon(Icons.info_outline),
            initiallyExpanded: true,
            child: Text('Hidden content appears here.'),
          ),
          gap(),
          const AppAccordion(title: 'Accordion closed', child: Text('x')),
        ],
      ),
    ),
  );
}

void main() {
  for (final scale in [1.0, 2.0]) {
    for (final mode in goldenModes) {
      testWidgets('display gallery ${mode.name} x$scale', (tester) async {
        final image = await _gradient(tester);
        await pumpDs(
          tester,
          _gallery(image),
          locale: mode.locale,
          dark: mode.dark,
          textScale: scale,
          size: Size(400, scale > 1 ? 2400 : 1300),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            '../../../../goldens/display/gallery_${mode.name}_x${scale.toInt()}.png',
          ),
        );
      });
    }
  }
}
