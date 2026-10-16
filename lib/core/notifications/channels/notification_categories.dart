/// iOS notification categories and their action ids. A [LocalNotification]
/// with `categoryId: NotificationCategories.message` shows the buttons below.
/// Action presses arrive as `NotificationTap.actionId` (and `input` for the
/// inline reply).
abstract final class NotificationCategories {
  /// A conversation-style notification with a reply field and "mark as read".
  static const message = 'message';

  static const replyAction = 'reply';
  static const markReadAction = 'mark_read';
}
