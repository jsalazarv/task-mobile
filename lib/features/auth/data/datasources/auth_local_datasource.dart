import 'package:hometasks/features/auth/data/models/auth_token_model.dart';
import 'package:hometasks/features/auth/data/models/user_model.dart';

/// Contrato del datasource local de autenticación.
abstract interface class AuthLocalDataSource {
  /// Persiste el usuario y el token tras un login/register exitoso.
  Future<void> saveSession({
    required UserModel user,
    required AuthTokenModel token,
  });

  /// Retorna el usuario persistido o null si no hay sesión.
  Future<UserModel?> getCachedUser();

  /// Retorna el token persistido o null si no hay sesión.
  Future<AuthTokenModel?> getCachedToken();

  /// Elimina todos los datos de sesión del almacenamiento local.
  Future<void> clearSession();

  /// Indica si existe un usuario guardado en local.
  Future<bool> get hasSession;
}
