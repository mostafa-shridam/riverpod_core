import 'package:flutter/foundation.dart';

/// Where a video comes from.
@immutable
sealed class AppVideoSource {
  const AppVideoSource();

  const factory AppVideoSource.network(String url) = AppVideoNetworkSource;
  const factory AppVideoSource.asset(String path) = AppVideoAssetSource;
  const factory AppVideoSource.file(String path) = AppVideoFileSource;
}

class AppVideoNetworkSource extends AppVideoSource {
  const AppVideoNetworkSource(this.url);
  final String url;

  @override
  bool operator ==(Object other) =>
      other is AppVideoNetworkSource && other.url == url;

  @override
  int get hashCode => Object.hash('network', url);
}

class AppVideoAssetSource extends AppVideoSource {
  const AppVideoAssetSource(this.path);
  final String path;

  @override
  bool operator ==(Object other) =>
      other is AppVideoAssetSource && other.path == path;

  @override
  int get hashCode => Object.hash('asset', path);
}

class AppVideoFileSource extends AppVideoSource {
  const AppVideoFileSource(this.path);
  final String path;

  @override
  bool operator ==(Object other) =>
      other is AppVideoFileSource && other.path == path;

  @override
  int get hashCode => Object.hash('file', path);
}
