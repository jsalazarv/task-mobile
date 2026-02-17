import 'package:dartz/dartz.dart';
import 'package:hometasks/core/error/failures.dart';
import 'package:hometasks/features/auth/domain/entities/auth_token_entity.dart';
import 'package:hometasks/features/auth/domain/entities/user_entity.dart';

/// Contrato del repositorio de autenticación.
/// La capa de dominio depende de esta abstracción — nunca de la implementación.
abstract interface class AuthRepository {
  /// Inicia sesión con email y contraseña.
  /// Retorna el [UserEntity] autenticado o un [Failure].
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario.
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual y limpia el almacenamiento local.
  Future<Either<Failure, Unit>> logout();

  /// Retorna el usuario actualmente autenticado desde el almacenamiento local.
  /// Retorna [Left(UnauthorizedFailure)] si no hay sesión activa.
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Renueva el access token usando el refresh token almacenado.
  Future<Either<Failure, AuthTokenEntity>> refreshToken();

  /// Indica si existe una sesión activa en el almacenamiento local.
  Future<bool> get isAuthenticated;
}
