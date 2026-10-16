import 'package:flutter/material.dart';

/// Demo destination for deep links and notification taps (`/items/:id`).
class ItemDetailPage extends StatelessWidget {
  static const routeName = '/items';

  const ItemDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('item-detail-page'),
      body: Center(child: Text(id)),
    );
  }
}
