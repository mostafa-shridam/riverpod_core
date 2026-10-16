import 'dart:convert';

import 'package:flutter/foundation.dart';

/// What a notification asks the app to open. The payload contract is the same
/// for push (`message.data`) and local notifications (JSON in `payload`):
/// `type` and `id` select a typed route, `url` opens an external page; every
/// other key is kept in [extra].
@immutable
class NotificationPayload {
  const NotificationPayload({
    this.type,
    this.id,
    this.url,
    this.extra = const {},
  });

  /// Reads the contract from FCM `data` or any decoded JSON map. Blank values
  /// count as missing; non-string values are stringified.
  factory NotificationPayload.fromData(Map<String, Object?> data) {
    String? text(String key) {
      final value = data[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    return NotificationPayload(
      type: text('type'),
      id: text('id'),
      url: text('url'),
      extra: {
        for (final entry in data.entries)
          if (!_reserved.contains(entry.key) && entry.value != null)
            entry.key: entry.value.toString(),
      },
    );
  }

  /// Parses the JSON stored in a local notification. Null when [raw] is empty,
  /// not JSON or not a JSON object: a bad payload must never crash a tap.
  static NotificationPayload? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) return null;
      return NotificationPayload.fromData(decoded);
    } on FormatException {
      return null;
    }
  }

  static const _reserved = {'type', 'id', 'url'};

  /// Route selector, for example `order`. Mapped by `routeForDeepLink`.
  final String? type;

  /// Identifier of the thing to open.
  final String? id;

  /// External `http(s)` page, used when there is no route.
  final String? url;

  /// Any other data keys, untouched.
  final Map<String, String> extra;

  /// True when both [type] and [id] are present.
  bool get hasRoute => type != null && id != null;

  /// True when there is a [url].
  bool get hasUrl => url != null;

  /// True when the payload asks for nothing.
  bool get isEmpty => !hasRoute && !hasUrl;

  /// The JSON stored in a local notification's payload.
  String toJson() => jsonEncode({
    ...extra,
    if (type != null) 'type': type,
    if (id != null) 'id': id,
    if (url != null) 'url': url,
  });

  @override
  bool operator ==(Object other) =>
      other is NotificationPayload &&
      other.type == type &&
      other.id == id &&
      other.url == url &&
      mapEquals(other.extra, extra);

  @override
  int get hashCode => Object.hash(
    type,
    id,
    url,
    Object.hashAllUnordered(
      extra.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  String toString() => 'NotificationPayload(type: $type, id: $id, url: $url)';
}
