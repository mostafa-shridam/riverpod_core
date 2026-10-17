import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps frames until [finder] matches, or fails after [timeout]. The app has
/// spinners and timers, so `pumpAndSettle` would never return.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (!tester.any(finder)) {
    if (DateTime.now().isAfter(end)) {
      // What is on screen, so a missed step can be read from the log.
      debugDumpApp();
      throw TestFailure('Not found within $timeout: $finder');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pump();
}

/// Taps [finder] once it is on screen, then pumps one frame.
Future<void> tapWhenFound(WidgetTester tester, Finder finder) async {
  await pumpUntilFound(tester, finder);
  // Let page and route animations finish: a tap during one misses the target.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.tap(finder);
  await tester.pump();
}

/// Pops the top route through its navigator, then waits until no route
/// transition is absorbing taps. Used instead of `pageBack`: the video detail
/// page showed no back button for `pageBack` to tap (C-26).
Future<void> popRoute(WidgetTester tester) async {
  Navigator.of(tester.element(find.byType(AppBar).last)).pop();
  await tester.pump();
  await waitForTransitions(tester);
}

/// Pumps until no `AbsorbPointer` is absorbing and no animation is running (a
/// route transition still in progress), or fails after 10 s.
Future<void> waitForTransitions(WidgetTester tester) async {
  final end = DateTime.now().add(const Duration(seconds: 10));
  bool absorbing() => tester
      .widgetList<AbsorbPointer>(find.byType(AbsorbPointer))
      .any((w) => w.absorbing);
  // Also wait for running animations (frame callbacks) to finish.
  bool busy() =>
      absorbing() || SchedulerBinding.instance.transientCallbackCount > 0;
  while (busy()) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure(
        'A route transition is still absorbing taps after 10 s',
      );
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}
