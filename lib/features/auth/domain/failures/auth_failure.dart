import 'package:hometasks/core/error/failures.dart';

/// Credenciales incorrectas (email o contraseña).
final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure()
      : super(message: 'Correo o contraseña incorrectos');
}

/// El email ya está registrado.
final class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure()
      : super(message: 'Este correo ya está registrado');
}

/// El usuario no tiene una sesión activa.
final class NoSessionFailure extends Failure {
  const NoSessionFailure()
      : super(message: 'No hay una sesión activa');
}

/// El refresh token expiró o es inválido — requiere login de nuevo.
final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure()
      : super(message: 'La sesión expiró, inicia sesión de nuevo');
}

/// El email del usuario no ha sido verificado.
final class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure()
      : super(message: 'Verifica tu correo electrónico antes de continuar');
}
