import 'package:equatable/equatable.dart';
import 'package:hometasks/features/auth/domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial — aún no se sabe si hay sesión.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Verificando sesión local al arrancar la app.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Usuario autenticado correctamente.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// Sin sesión activa.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Operación de login/register en curso.
final class AuthSubmitting extends AuthState {
  const AuthSubmitting();
}

/// Error durante login, register o logout.
final class AuthFailure extends AuthState {
  const AuthFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
