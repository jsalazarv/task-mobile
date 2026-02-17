import 'package:hometasks/core/storage/hive_service.dart';
import 'package:injectable/injectable.dart';

/// Manager para operaciones de caché con tiempo de expiración
@lazySingleton
class CacheManager {
  CacheManager(this._hiveService);

  final HiveService _hiveService;

  static const String _timestampSuffix = '_timestamp';
  static const Duration _defaultCacheDuration = Duration(hours: 1);

  /// Guarda datos en caché con timestamp
  Future<void> saveWithExpiry({
    required String key,
    required dynamic data,
    Duration? duration,
  }) async {
    final expiry = duration ?? _defaultCacheDuration;
    final timestampKey = '$key$_timestampSuffix';
    final expiryTime = DateTime.now().add(expiry).millisecondsSinceEpoch;

    await Future.wait([
      _hiveService.saveCache(key, data),
      _hiveService.saveCache(timestampKey, expiryTime),
    ]);
  }

  /// Obtiene datos del caché si no han expirado
  T? getIfValid<T>(String key) {
    final timestampKey = '$key$_timestampSuffix';
    final expiryTime = _hiveService.getCache(timestampKey) as int?;

    if (expiryTime == null) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > expiryTime) {
      // Cache expirado, eliminarlo
      _hiveService
        ..removeCache(key)
        ..removeCache(timestampKey);
      return null;
    }

    return _hiveService.getCache(key) as T?;
  }

  /// Verifica si el caché es válido
  bool isValid(String key) {
    final timestampKey = '$key$_timestampSuffix';
    final expiryTime = _hiveService.getCache(timestampKey) as int?;

    if (expiryTime == null) {
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    return now <= expiryTime;
  }

  /// Invalida (elimina) un caché específico
  Future<void> invalidate(String key) async {
    final timestampKey = '$key$_timestampSuffix';
    await Future.wait([
      _hiveService.removeCache(key),
      _hiveService.removeCache(timestampKey),
    ]);
  }

  /// Invalida todos los cachés
  Future<void> invalidateAll() async {
    await _hiveService.clearCacheBox();
  }
}
