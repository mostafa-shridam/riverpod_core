import 'package:hive_flutter/adapters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:riverpod_core/core/enum/constants.dart';

part 'local_storage.g.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  LocalStorage._internal();
  static LocalStorage get instance => _instance;
  late Box<dynamic> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(Constants.mainBox.name);
  }

  Future<void> add(String key, dynamic value) async {
    await _box.put(key, value);
  }

  dynamic get(String key) {
    final data = _box.get(key);
    return data;
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }
}

@riverpod
LocalStorage localStorage(Ref ref) => LocalStorage.instance;
