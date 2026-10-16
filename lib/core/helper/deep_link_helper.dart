import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:riverpod_core/core/helper/help_functions.dart';

/// A deep-link request from a notification payload: what to open and which id.
typedef DeepLinkEvent = ({String type, String id});

/// Bridge from notification taps to the router.
///
/// TEMPORARY (C-11): the notification services call [handleRouteById] and this
/// helper emits a [DeepLinkEvent] on [events]. The app router maps the event
/// to a typed route. Core must not import `app/`, so the mapping lives there.
/// C-20 replaces this bridge with the notification provider.
class DeepLinkHelper {
  DeepLinkHelper._();
  static final DeepLinkHelper _instance = DeepLinkHelper._();
  static DeepLinkHelper get instance => _instance;

  final StreamController<DeepLinkEvent> _events =
      StreamController<DeepLinkEvent>.broadcast();

  Stream<DeepLinkEvent> get events => _events.stream;

  Future<void> handleRouteById({required String pyload}) async {
    log('🔔 Attempting foreground navigation for payload: $pyload');

    final convert = jsonDecode(pyload) as Map<String, dynamic>;
    final id = convert['id'] as String?;
    final type = convert['page'] as String?;

    if (id == null || type == null) {
      log('❌ Invalid payload');
      return;
    }

    _events.add((type: type, id: id));
    log('✅ Navigation requested');
  }

  Future<void> launchUrl(String pyload) async {
    final convert = jsonDecode(pyload) as Map<String, dynamic>;
    final url = convert['url'] as String?;

    if (url == null) {
      log('❌ Invalid payload: URL is missing');
      return;
    } else {
      log('🔗 Launching URL: $url');
      await myLaunchURL(url);
    }
  }
}
