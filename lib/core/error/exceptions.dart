/// Excepción base para todas las excepciones personalizadas
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final dynamic details;

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Excepción cuando el servidor devuelve un error
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'ServerException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Excepción cuando falla el caché local
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Excepción cuando no hay conexión a internet
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
    super.details,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Excepción cuando la autenticación falla
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'AuthenticationException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Excepción cuando el token es inválido o expiró
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized access',
    super.code,
    super.details,
  });

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Excepción cuando la validación de datos falla
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Excepción cuando se intenta acceder a un recurso que no existe
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'NotFoundException: $message';
}
