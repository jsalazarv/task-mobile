import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los Failures
/// Los Failures representan errores en el domain layer
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Failure cuando hay un error en el servidor
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.code,
  });

  @override
  String toString() => 'ServerFailure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Failure cuando hay un error con el caché
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.code,
  });

  @override
  String toString() => 'CacheFailure: $message';
}

/// Failure cuando no hay conexión a internet
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code,
  });

  @override
  String toString() => 'NetworkFailure: $message';
}

/// Failure cuando la autenticación falla
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed',
    super.code,
  });

  @override
  String toString() => 'AuthenticationFailure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Failure cuando el usuario no está autorizado
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Unauthorized access',
    super.code,
  });

  @override
  String toString() => 'UnauthorizedFailure: $message';
}

/// Failure cuando la validación de datos falla
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'ValidationFailure: $message';
}

/// Failure cuando un recurso no se encuentra
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
    super.code,
  });

  @override
  String toString() => 'NotFoundFailure: $message';
}

/// Failure genérico para errores inesperados
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred',
    super.code,
  });

  @override
  String toString() => 'UnexpectedFailure: $message';
}
