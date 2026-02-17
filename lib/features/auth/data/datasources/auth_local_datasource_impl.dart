import 'dart:convert';

import 'package:hometasks/core/error/exceptions.dart';
import 'package:hometasks/core/storage/hive_service.dart';
import 'package:hometasks/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:hometasks/features/auth/data/models/auth_token_model.dart';
import 'package:hometasks/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._hive);

  final HiveService _hive;

  static const _keyUser  = 'cached_user';
  static const _keyToken = 'cached_token';

  @override
  Future<void> saveSession({
    required UserModel user,
    required AuthTokenModel token,
  }) async {
    try {
      await Future.wait([
        _hive.saveUser(_keyUser,  jsonEncode(user.toJson())),
        _hive.saveUser(_keyToken, jsonEncode(token.toJson())),
      ]);
    } catch (e) {
      throw CacheException(message: 'Error al guardar la sesión: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final raw = _hive.getUser(_keyUser) as String?;
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException(message: 'Error al leer el usuario en caché: $e');
    }
  }

  @override
  Future<AuthTokenModel?> getCachedToken() async {
    try {
      final raw = _hive.getUser(_keyToken) as String?;
      if (raw == null) return null;
      return AuthTokenModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException(message: 'Error al leer el token en caché: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await Future.wait([
        _hive.removeUser(_keyUser),
        _hive.removeUser(_keyToken),
      ]);
    } catch (e) {
      throw CacheException(message: 'Error al limpiar la sesión: $e');
    }
  }

  @override
  Future<bool> get hasSession async {
    final user = _hive.getUser(_keyUser);
    return user != null;
  }
}
