import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/notifications/notification_service_provider.dart';

/// Creates the notification channels, groups and iOS action titles in the
/// current language once translations are loaded (first frame), and again
/// whenever the app language changes. Mount it once, inside the
/// `EasyLocalization` subtree (`MaterialApp.builder`). Never blocks the UI.
class NotificationLabelSync extends ConsumerStatefulWidget {
  const NotificationLabelSync({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationLabelSync> createState() =>
      _NotificationLabelSyncState();
}

class _NotificationLabelSyncState extends ConsumerState<NotificationLabelSync> {
  Locale? _synced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale;
    if (locale == _synced) return;
    _synced = locale;
    // After the frame: the new translations are applied by then.
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_sync()));
  }

  Future<void> _sync() async {
    if (!mounted) return;
    final service = ref.read(notificationServiceProvider);
    // initialize() is idempotent and never throws; channels need the plugin.
    await service.initialize();
    await service.syncChannelLabels();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
