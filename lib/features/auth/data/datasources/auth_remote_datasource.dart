import 'package:hometasks/features/auth/data/models/auth_response_model.dart';
import 'package:hometasks/features/auth/data/models/auth_token_model.dart';

/// Contrato del datasource remoto de autenticación.
abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<AuthTokenModel> refreshToken(String refreshToken);
}
