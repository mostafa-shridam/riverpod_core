import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('home-page'),
      appBar: AppBar(title: Text('app_nav.home'.tr())),
    );
  }
}
