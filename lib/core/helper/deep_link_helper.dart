import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:riverpod_core/core/helper/help_functions.dart';

class DeepLinkHelper {
  DeepLinkHelper._();
  static final DeepLinkHelper _instance = DeepLinkHelper._();
  static DeepLinkHelper get instance => _instance;

  Future<void> handleRouteById({required String pyload}) async {
    // final router = MobileRouting.instance.router;
    log('🔔 Attempting foreground navigation for payload: $pyload');

    final convert = jsonDecode(pyload) as Map<String, dynamic>;
    final id = convert['id'] as String?;
    final type = convert['page'] as String?;

    if (id == null || type == null) {
      log('❌ Invalid payload');
      return;
    }

    unawaited(
      Future<void>.microtask(() async {
        switch (type) {
          case 'myEvents':
            // router.goNamed(page name here.routeName);
            // router.pushNamed(
            //   MyEventDetailsPage.routeName,
            //   pathParameters: {'id': id},
            // );
            break;

          default:
            // router.goNamed(MainPage.routeName);
            log('❌ Unsupported navigation type: $type');
        }
      }),
    );

    log('✅ Navigation executed successfully');
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
