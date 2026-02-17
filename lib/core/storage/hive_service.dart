import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HiveService {
  // Box names
  static const String _userBox = 'user_box';
  static const String _cacheBox = 'cache_box';

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters here when needed
    // Hive.registerAdapter(UserModelAdapter());

    // Open boxes
    await Future.wait([
      Hive.openBox<dynamic>(_userBox),
      Hive.openBox<dynamic>(_cacheBox),
    ]);

    _isInitialized = true;
  }

  // User Box operations
  Box<dynamic> get userBox => Hive.box<dynamic>(_userBox);

  Future<void> saveUser(String key, dynamic value) async {
    await userBox.put(key, value);
  }

  dynamic getUser(String key) {
    return userBox.get(key);
  }

  Future<void> removeUser(String key) async {
    await userBox.delete(key);
  }

  Future<void> clearUserBox() async {
    await userBox.clear();
  }

  // Cache Box operations
  Box<dynamic> get cacheBox => Hive.box<dynamic>(_cacheBox);

  Future<void> saveCache(String key, dynamic value) async {
    await cacheBox.put(key, value);
  }

  dynamic getCache(String key) {
    return cacheBox.get(key);
  }

  Future<void> removeCache(String key) async {
    await cacheBox.delete(key);
  }

  Future<void> clearCacheBox() async {
    await cacheBox.clear();
  }

  // Generic operations
  Future<void> saveData({
    required String boxName,
    required String key,
    required dynamic value,
  }) async {
    final box = await Hive.openBox<dynamic>(boxName);
    await box.put(key, value);
  }

  Future<T?> getData<T>({
    required String boxName,
    required String key,
  }) async {
    final box = await Hive.openBox<dynamic>(boxName);
    return box.get(key) as T?;
  }

  Future<void> removeData({
    required String boxName,
    required String key,
  }) async {
    final box = await Hive.openBox<dynamic>(boxName);
    await box.delete(key);
  }

  Future<void> clearBox(String boxName) async {
    final box = await Hive.openBox<dynamic>(boxName);
    await box.clear();
  }

  // Clear all Hive data
  Future<void> clearAll() async {
    await Hive.deleteFromDisk();
    _isInitialized = false;
  }

  // Close all boxes
  Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }
}
