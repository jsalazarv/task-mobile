import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hometasks/features/auth/domain/entities/auth_token_entity.dart';

part 'auth_token_model.freezed.dart';
part 'auth_token_model.g.dart';

/// Modelo de datos para el token de autenticación.
@freezed
class AuthTokenModel with _$AuthTokenModel {
  const factory AuthTokenModel({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
  }) = _AuthTokenModel;

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  const AuthTokenModel._();

  AuthTokenEntity toEntity() => AuthTokenEntity(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );

  static AuthTokenModel fromEntity(AuthTokenEntity entity) => AuthTokenModel(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
        expiresAt: entity.expiresAt,
      );
}
