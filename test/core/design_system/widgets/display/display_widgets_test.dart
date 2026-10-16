import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_accordion.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_avatar.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_badge.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_card.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_chip.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_divider.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_section_header.dart';

import 'ds_test_harness.dart';

Material _cardMaterial(WidgetTester tester) => tester.widget<Material>(
  find
      .descendant(of: find.byType(AppCard), matching: find.byType(Material))
      .first,
);

void main() {
  group('AppCard', () {
    testWidgets('filled and outlined are flat, elevated uses the low token', (
      tester,
    ) async {
      for (final v in AppCardVariant.values) {
        await pumpDs(
          tester,
          Center(
            child: AppCard(variant: v, child: const Text('x')),
          ),
        );
        final elevation = _cardMaterial(tester).elevation;
        expect(
          elevation,
          v == AppCardVariant.elevated ? 1.0 : 0.0,
          reason: '$v',
        );
      }
    });

    testWidgets('outlined draws a border, others do not', (tester) async {
      await pumpDs(
        tester,
        const Center(
          child: AppCard(variant: AppCardVariant.outlined, child: Text('x')),
        ),
      );
      final shape = _cardMaterial(tester).shape! as RoundedRectangleBorder;
      expect(shape.side.style, BorderStyle.solid);
      expect(shape.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('tappable cards call onTap and onLongPress', (tester) async {
      var taps = 0;
      var longs = 0;
      await pumpDs(
        tester,
        Center(
          child: AppCard(
            onTap: () => taps++,
            onLongPress: () => longs++,
            child: const Text('tap me'),
          ),
        ),
      );
      await tester.tap(find.text('tap me'));
      await tester.longPress(find.text('tap me'));
      expect(taps, 1);
      expect(longs, 1);
    });

    testWidgets('a static card has no ink response', (tester) async {
      await pumpDs(tester, const Center(child: AppCard(child: Text('x'))));
      expect(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
    });
  });

  group('AppListTile', () {
    testWidgets('shows slots and handles taps', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        AppListTile(
          leading: const Icon(Icons.person),
          title: const Text('Title'),
          subtitle: const Text('Subtitle'),
          showChevron: true,
          onTap: () => taps++,
        ),
      );
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      final chevron = tester.widget<Icon>(find.byIcon(Icons.chevron_right));
      expect(chevron.icon!.matchTextDirection, isTrue);
      await tester.tap(find.text('Title'));
      expect(taps, 1);
    });

    testWidgets('disabled ignores taps', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        AppListTile(
          title: const Text('Title'),
          enabled: false,
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.text('Title'));
      expect(taps, 0);
    });

    testWidgets('selected is exposed to semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        AppListTile(title: const Text('Row'), selected: true, onTap: () {}),
      );
      expect(
        tester.getSemantics(find.byType(AppListTile)),
        matchesSemantics(
          isSelected: true,
          isEnabled: true,
          hasEnabledState: true,
          hasSelectedState: true,
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
          label: 'Row',
        ),
      );
      handle.dispose();
    });

    testWidgets('is at least 48 dp tall and survives text scale 2.0', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const AppListTile(
          title: Text('A fairly long title that has to wrap at large scale'),
          subtitle: Text('And a subtitle that also wraps around nicely'),
          trailing: Icon(Icons.star),
        ),
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AppListTile)).height, greaterThan(48));
    });
  });

  group('AppSectionHeader', () {
    testWidgets('renders title, subtitle and trailing as a header', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const AppSectionHeader(
          title: 'Recent',
          subtitle: 'Last 7 days',
          trailing: Text('See all'),
        ),
      );
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('Last 7 days'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Recent')),
        matchesSemantics(label: 'Recent', isHeader: true),
      );
      handle.dispose();
    });
  });

  group('AppDivider', () {
    testWidgets('start inset follows the reading direction', (tester) async {
      await pumpDs(
        tester,
        const Align(
          alignment: Alignment.topCenter,
          child: AppDivider(inset: AppDividerInset.start),
        ),
      );
      expect(tester.getTopLeft(find.byType(Divider)).dx, 16);
      await pumpDs(
        tester,
        const Align(
          alignment: Alignment.topCenter,
          child: AppDivider(inset: AppDividerInset.start),
        ),
        locale: 'ar',
      );
      expect(tester.getTopRight(find.byType(Divider)).dx, phoneSize.width - 16);
    });

    testWidgets('both inset on both sides, none full width', (tester) async {
      await pumpDs(
        tester,
        const Align(
          alignment: Alignment.topCenter,
          child: AppDivider(inset: AppDividerInset.both),
        ),
      );
      expect(tester.getSize(find.byType(Divider)).width, phoneSize.width - 32);
      await pumpDs(
        tester,
        const Align(alignment: Alignment.topCenter, child: AppDivider()),
      );
      expect(tester.getSize(find.byType(Divider)).width, phoneSize.width);
    });

    testWidgets('label sits between two lines', (tester) async {
      await pumpDs(tester, const AppDivider(label: 'or'));
      expect(find.text('or'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('vertical variant builds a VerticalDivider', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(height: 40, child: AppDivider.vertical()),
      );
      expect(find.byType(VerticalDivider), findsOneWidget);
    });
  });

  group('AppAvatar', () {
    test('initialsOf takes first and last word, Arabic included', () {
      expect(AppAvatar.initialsOf('Ada Lovelace'), 'AL');
      expect(AppAvatar.initialsOf('ada'), 'A');
      expect(AppAvatar.initialsOf('  Jean  Luc  Picard '), 'JP');
      expect(AppAvatar.initialsOf('محمد علي'), 'مع');
      expect(AppAvatar.initialsOf('   '), '');
    });

    testWidgets('shows initials, else the icon', (tester) async {
      await pumpDs(tester, const Center(child: AppAvatar(name: 'Ada Byron')));
      expect(find.text('AB'), findsOneWidget);
      await pumpDs(tester, const Center(child: AppAvatar()));
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('sizes map to diameters', (tester) async {
      for (final s in AppAvatarSize.values) {
        await pumpDs(
          tester,
          Center(
            child: AppAvatar(name: 'A B', size: s),
          ),
        );
        expect(tester.getSize(find.byType(AppAvatar)), Size.square(s.diameter));
      }
    });

    testWidgets('status dot sits at the end corner in LTR and RTL', (
      tester,
    ) async {
      Future<Rect> dotRect(String locale) async {
        await pumpDs(
          tester,
          const Center(
            child: AppAvatar(name: 'A B', status: AppAvatarStatus.online),
          ),
          locale: locale,
        );
        final avatar = tester.getRect(find.byType(AppAvatar));
        final dot = tester.getRect(
          find
              .descendant(
                of: find.byType(AppAvatar),
                matching: find.byType(Container),
              )
              .last,
        );
        expect(dot.bottom, avatar.bottom);
        return Rect.fromLTRB(
          dot.left - avatar.left,
          dot.top,
          dot.right - avatar.left,
          dot.bottom,
        );
      }

      final avatarWidth = AppAvatarSize.md.diameter;
      expect((await dotRect('en')).right, avatarWidth);
      expect((await dotRect('ar')).left, 0);
    });

    testWidgets('a broken image falls back to initials', (tester) async {
      await pumpDs(
        tester,
        Center(
          child: AppAvatar(name: 'Ada Byron', imageProvider: _BrokenImage()),
        ),
      );
      await tester.pump();
      expect(find.text('AB'), findsOneWidget);
    });
  });

  group('AppBadge', () {
    testWidgets('shows the count', (tester) async {
      await pumpDs(tester, const Center(child: AppBadge(count: 5)));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('overflows to 99+ and honors maxCount', (tester) async {
      await pumpDs(tester, const Center(child: AppBadge(count: 120)));
      expect(find.text('99+'), findsOneWidget);
      await pumpDs(
        tester,
        const Center(child: AppBadge(count: 12, maxCount: 9)),
      );
      expect(find.text('9+'), findsOneWidget);
      await pumpDs(tester, const Center(child: AppBadge(count: 99)));
      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('zero is hidden unless showZero', (tester) async {
      await pumpDs(tester, const Center(child: AppBadge(count: 0)));
      expect(find.text('0'), findsNothing);
      await pumpDs(
        tester,
        const Center(child: AppBadge(count: 0, showZero: true)),
      );
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('dot has no text and wraps its child', (tester) async {
      await pumpDs(
        tester,
        const Center(child: AppBadge.dot(child: Icon(Icons.mail))),
      );
      expect(find.byIcon(Icons.mail), findsOneWidget);
      expect(find.byType(Text), findsNothing);
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
    });

    testWidgets('formatter localizes digits', (tester) async {
      await pumpDs(
        tester,
        Center(child: AppBadge(count: 120, formatter: (v) => 'n$v')),
      );
      expect(find.text('n99+'), findsOneWidget);
    });

    testWidgets('anchors to the end of its child', (tester) async {
      Future<double> offset(String locale) async {
        await pumpDs(
          tester,
          const Center(
            child: AppBadge(count: 3, child: SizedBox(width: 40, height: 40)),
          ),
          locale: locale,
        );
        return tester.getCenter(find.text('3')).dx -
            tester.getCenter(find.byType(SizedBox).last).dx;
      }

      expect(await offset('en'), greaterThan(0));
      expect(await offset('ar'), lessThan(0));
    });
  });

  group('AppChip', () {
    testWidgets('plain tag shows its label and icon', (tester) async {
      await pumpDs(
        tester,
        const Center(
          child: AppChip(label: 'Tag', icon: Icons.tag),
        ),
      );
      expect(find.text('Tag'), findsOneWidget);
      expect(find.byIcon(Icons.tag), findsOneWidget);
    });

    testWidgets('filter chip reports selection', (tester) async {
      bool? value;
      await pumpDs(
        tester,
        Center(
          child: AppChip(label: 'Filter', onSelected: (v) => value = v),
        ),
      );
      await tester.tap(find.text('Filter'));
      expect(value, isTrue);
      await pumpDs(
        tester,
        Center(
          child: AppChip(
            label: 'Filter',
            selected: true,
            onSelected: (v) => value = v,
          ),
        ),
      );
      expect(tester.widget<RawChip>(find.byType(RawChip)).selected, isTrue);
      await tester.tap(find.text('Filter'));
      expect(value, isFalse);
    });

    testWidgets('delete icon calls onDeleted', (tester) async {
      var deleted = 0;
      await pumpDs(
        tester,
        Center(
          child: AppChip(label: 'Input', onDeleted: () => deleted++),
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(deleted, 1);
    });

    testWidgets('action chip calls onTap', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        Center(
          child: AppChip(label: 'Act', onTap: () => taps++),
        ),
      );
      await tester.tap(find.text('Act'));
      expect(taps, 1);
    });

    testWidgets('every tone builds', (tester) async {
      for (final tone in AppChipTone.values) {
        await pumpDs(
          tester,
          Center(
            child: AppChip(label: tone.name, tone: tone),
          ),
        );
        expect(find.text(tone.name), findsOneWidget);
      }
    });
  });

  group('AppAccordion', () {
    testWidgets('collapsed hides content, tap expands and collapses', (
      tester,
    ) async {
      final changes = <bool>[];
      await pumpDs(
        tester,
        AppAccordion(
          title: 'Details',
          onExpansionChanged: changes.add,
          child: const Text('Body'),
        ),
      );
      expect(find.text('Body'), findsNothing);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
      expect(changes, [true, false]);
    });

    testWidgets('initiallyExpanded shows content and exposes semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const AppAccordion(
          title: 'Details',
          initiallyExpanded: true,
          child: Text('Body'),
        ),
      );
      expect(find.text('Body'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Details')),
        isSemantics(isExpanded: true, isButton: true),
      );
      handle.dispose();
    });

    testWidgets('survives text scale 2.0 in Arabic', (tester) async {
      await pumpDs(
        tester,
        const AppAccordion(
          title: 'عنوان طويل جدا يلتف على أكثر من سطر عند التكبير',
          subtitle: 'وصف قصير',
          initiallyExpanded: true,
          leading: Icon(Icons.info),
          child: Text('محتوى'),
        ),
        locale: 'ar',
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

class _BrokenImage extends ImageProvider<_BrokenImage> {
  @override
  Future<_BrokenImage> obtainKey(ImageConfiguration configuration) =>
      Future.value(this);

  @override
  ImageStreamCompleter loadImage(
    _BrokenImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    Future<ImageInfo>.error(Exception('broken')),
  );
}
