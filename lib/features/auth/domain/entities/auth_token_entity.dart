import 'package:equatable/equatable.dart';

/// Token de autenticación con su fecha de expiración.
class AuthTokenEntity extends Equatable {
  const AuthTokenEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Tiempo restante antes de expiración.
  Duration get remainingTime => expiresAt.difference(DateTime.now());

  @override
  List<Object> get props => [accessToken, refreshToken, expiresAt];
}
