import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hometasks/features/auth/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Modelo de datos para serialización/deserialización del usuario.
/// Mapea desde/hacia JSON y hacia la entidad de dominio [UserEntity].
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'email_verified') @Default(false) bool emailVerified,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  const UserModel._();

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        emailVerified: emailVerified,
        createdAt: createdAt,
      );

  static UserModel fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        email: entity.email,
        name: entity.name,
        avatarUrl: entity.avatarUrl,
        emailVerified: entity.emailVerified,
        createdAt: entity.createdAt,
      );
}
