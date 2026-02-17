import 'package:hometasks/core/error/exceptions.dart';
import 'package:hometasks/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:hometasks/features/auth/data/models/auth_response_model.dart';
import 'package:hometasks/features/auth/data/models/auth_token_model.dart';
import 'package:hometasks/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

/// Implementación mock del datasource remoto.
/// Simula respuestas reales de la API con delays para imitar latencia de red.
/// Se reemplazará con llamadas Dio reales cuando el backend esté listo.
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Usuarios en memoria para el mock
  final _users = <String, _MockUser>{};

  static const _mockDelay = Duration(milliseconds: 800);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_mockDelay);

    final mockUser = _users[email];

    if (mockUser == null || mockUser.password != password) {
      throw const AuthenticationException(
        message: 'Correo o contraseña incorrectos',
        code: 'invalid_credentials',
      );
    }

    return _buildAuthResponse(mockUser);
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_mockDelay);

    if (_users.containsKey(email)) {
      throw const ServerException(
        message: 'Este correo ya está registrado',
        code: 'email_already_in_use',
      );
    }

    final newUser = _MockUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      password: password,
      createdAt: DateTime.now(),
    );

    _users[email] = newUser;

    return _buildAuthResponse(newUser);
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    await Future<void>.delayed(_mockDelay);

    // Mock: valida que el refresh token no esté vacío
    if (refreshToken.isEmpty) {
      throw const UnauthorizedException(
        message: 'Refresh token inválido',
        code: 'invalid_refresh_token',
      );
    }

    return AuthTokenModel(
      accessToken: 'mock_access_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  AuthResponseModel _buildAuthResponse(_MockUser user) {
    return AuthResponseModel(
      user: UserModel(
        id: user.id,
        email: user.email,
        name: user.name,
        emailVerified: true,
        createdAt: user.createdAt,
      ),
      token: AuthTokenModel(
        accessToken: 'mock_access_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_${user.id}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }
}

class _MockUser {
  const _MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;
}
