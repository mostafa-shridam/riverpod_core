import 'package:flutter/foundation.dart';
import 'package:riverpod_core/core/notifications/models/local_notification.dart';
import 'package:riverpod_core/core/notifications/models/schedule_repeat.dart';

/// A [notification] to show at [when], optionally repeating.
@immutable
class ScheduledNotification {
  const ScheduledNotification({
    required this.notification,
    required this.when,
    required this.exact,
    this.repeat = ScheduleRepeat.none,
  });

  final LocalNotification notification;

  /// First moment to show it, in the device's local time.
  final DateTime when;

  /// True: use an exact alarm. False: let the system batch it (it may arrive
  /// a few minutes late).
  final bool exact;
  final ScheduleRepeat repeat;
}
