import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa un usuario autenticado.
/// Inmutable — no contiene lógica de UI ni de datos.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.emailVerified = false,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final bool emailVerified;
  final DateTime createdAt;

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        emailVerified,
        createdAt,
      ];
}
