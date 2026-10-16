import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/design_system/responsive/breakpoints.dart';
import 'package:riverpod_core/design_system/responsive/responsive_layout.dart';
import 'package:riverpod_core/design_system/responsive/text_scale.dart';

Future<void> _pumpAtWidth(
  WidgetTester tester,
  double width,
  Widget child, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 800);
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 800), textScaler: textScaler),
      child: MaterialApp(home: child),
    ),
  );
}

void main() {
  group('breakpointForWidth', () {
    test('resolves the boundaries at 599/600/1023/1024', () {
      expect(breakpointForWidth(0), AppBreakpoint.phone);
      expect(breakpointForWidth(599), AppBreakpoint.phone);
      expect(breakpointForWidth(600), AppBreakpoint.tablet);
      expect(breakpointForWidth(1023), AppBreakpoint.tablet);
      expect(breakpointForWidth(1024), AppBreakpoint.desktop);
      expect(breakpointForWidth(4000), AppBreakpoint.desktop);
    });
  });

  testWidgets('context.breakpoint follows the window width', (tester) async {
    late AppBreakpoint seen;
    await _pumpAtWidth(
      tester,
      1024,
      Builder(
        builder: (context) {
          seen = context.breakpoint;
          return const SizedBox();
        },
      ),
    );
    expect(seen, AppBreakpoint.desktop);
  });

  testWidgets('ResponsiveLayout picks the layout for the width class', (
    tester,
  ) async {
    const layout = ResponsiveLayout(
      phone: Text('phone'),
      tablet: Text('tablet'),
      desktop: Text('desktop'),
    );

    await _pumpAtWidth(tester, 500, layout);
    expect(find.text('phone'), findsOneWidget);

    await _pumpAtWidth(tester, 800, layout);
    expect(find.text('tablet'), findsOneWidget);

    await _pumpAtWidth(tester, 1200, layout);
    expect(find.text('desktop'), findsOneWidget);
  });

  testWidgets('ResponsiveLayout falls back to the smaller layout', (
    tester,
  ) async {
    const layout = ResponsiveLayout(phone: Text('phone'));
    await _pumpAtWidth(tester, 1200, layout);
    expect(find.text('phone'), findsOneWidget);
  });

  group('clampTextScale', () {
    test('keeps a scale inside 0.8..2.0 unchanged', () {
      expect(clampTextScale(const TextScaler.linear(1.3)).scale(10), 13);
    });

    test('raises below 0.8 and lowers above 2.0', () {
      expect(clampTextScale(const TextScaler.linear(0.5)).scale(10), 8);
      expect(clampTextScale(const TextScaler.linear(3)).scale(10), 20);
    });
  });

  testWidgets('text scale 2.0 is honored, not reset to 1.0', (tester) async {
    late double scaled;
    await _pumpAtWidth(
      tester,
      400,
      Builder(
        builder: (context) {
          scaled = MediaQuery.textScalerOf(context).scale(16);
          return const SizedBox();
        },
      ),
      textScaler: clampTextScale(const TextScaler.linear(2)),
    );
    expect(scaled, 32);
  });
}
