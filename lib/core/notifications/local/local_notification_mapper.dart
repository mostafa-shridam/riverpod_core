import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_core/core/notifications/models/local_notification.dart';
import 'package:riverpod_core/core/notifications/models/notification_importance.dart';

/// Builds plugin objects from the plugin-free models. Pure: unit-testable.
abstract final class LocalNotificationMapper {
  static Importance importance(NotificationImportance value) => switch (value) {
    NotificationImportance.low => Importance.low,
    NotificationImportance.normal => Importance.defaultImportance,
    NotificationImportance.high => Importance.high,
    NotificationImportance.max => Importance.max,
  };

  static Priority priority(NotificationImportance value) => switch (value) {
    NotificationImportance.low => Priority.low,
    NotificationImportance.normal => Priority.defaultPriority,
    NotificationImportance.high => Priority.high,
    NotificationImportance.max => Priority.max,
  };

  /// Details for [notification]. [channelName] is only used by the system when
  /// the channel does not exist yet.
  static NotificationDetails details(
    LocalNotification notification, {
    required NotificationImportance channelImportance,
    required String channelName,
    required String androidIcon,
    Color? accentColor,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        notification.channelId,
        channelName,
        icon: androidIcon,
        color: accentColor,
        importance: importance(channelImportance),
        priority: priority(channelImportance),
        styleInformation: _style(notification),
        groupKey: notification.groupKey,
        setAsGroupSummary: notification.isGroupSummary,
      ),
      iOS: DarwinNotificationDetails(
        badgeNumber: notification.badge,
        categoryIdentifier: notification.categoryId,
        threadIdentifier: notification.groupKey,
      ),
    );
  }

  static StyleInformation? _style(LocalNotification n) {
    if (n.isGroupSummary && n.groupLines.isNotEmpty) {
      return InboxStyleInformation(
        n.groupLines,
        contentTitle: n.title,
        summaryText: n.summaryText,
      );
    }
    final picture = n.bigPicturePath;
    if (picture != null) {
      return BigPictureStyleInformation(
        FilePathAndroidBitmap(picture),
        contentTitle: n.title,
        summaryText: n.bigText ?? n.body,
      );
    }
    final text = n.bigText;
    if (text != null) {
      return BigTextStyleInformation(
        text,
        contentTitle: n.title,
        summaryText: n.summaryText,
      );
    }
    return null;
  }

  /// Details of the silent notification that only sets the iOS badge.
  static NotificationDetails badgeOnly(int count) => NotificationDetails(
    iOS: DarwinNotificationDetails(
      presentAlert: false,
      presentBanner: false,
      presentList: false,
      presentSound: false,
      badgeNumber: count,
    ),
  );
}
