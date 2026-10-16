import 'package:riverpod_core/core/app_info/app_info.dart';
import 'package:riverpod_core/core/links/external_links.dart';
import 'package:riverpod_core/core/review/review_service.dart';
import 'package:riverpod_core/core/sharing/share_service.dart';

/// Records launched links; [result] is what the "platform" answers and
/// [error] makes it throw.
class FakeLinkBackend implements LinkBackend {
  FakeLinkBackend({this.result = true, this.error});

  bool result;
  Object? error;
  final List<Uri> launched = [];

  @override
  Future<bool> launch(Uri uri) async {
    launched.add(uri);
    if (error != null) throw error!;
    return result;
  }
}

/// Records what was shared; [error] makes every call throw.
class FakeShareBackend implements ShareBackend {
  FakeShareBackend({this.error});

  Object? error;
  final List<String> texts = [];
  final List<Uri> uris = [];
  final List<String> files = [];
  String? lastSubject;
  String? lastCaption;
  String? lastMimeType;

  Future<bool> _record(void Function() add) async {
    if (error != null) throw error!;
    add();
    return true;
  }

  @override
  Future<bool> shareText(String text, {String? subject}) => _record(() {
    texts.add(text);
    lastSubject = subject;
  });

  @override
  Future<bool> shareUri(Uri uri) => _record(() => uris.add(uri));

  @override
  Future<bool> shareFile(String path, {String? text, String? mimeType}) =>
      _record(() {
        files.add(path);
        lastCaption = text;
        lastMimeType = mimeType;
      });
}

/// Counts review calls; [available] decides in-app prompt vs store fallback.
class FakeReviewBackend implements ReviewBackend {
  FakeReviewBackend({this.available = true, this.error});

  bool available;
  Object? error;
  int requestCalls = 0;
  final List<String?> storeListingCalls = [];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    if (error != null) throw error!;
    requestCalls++;
  }

  @override
  Future<void> openStoreListing({String? appStoreId}) async {
    if (error != null) throw error!;
    storeListingCalls.add(appStoreId);
  }
}

/// Returns a fixed [AppInfo], or throws [error].
class FakeAppInfoSource implements AppInfoSource {
  FakeAppInfoSource(this.info, {this.error});

  AppInfo info;
  Object? error;

  @override
  Future<AppInfo> load() async {
    if (error != null) throw error!;
    return info;
  }
}
