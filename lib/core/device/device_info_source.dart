/// Raw device facts from the platform. Tests use a fake.
abstract interface class DeviceInfoSource {
  /// `android`, `ios` or `other`.
  Future<String> platform();

  Future<String> model();

  Future<String> osVersion();
}
