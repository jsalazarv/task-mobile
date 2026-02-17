import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hometasks/features/auth/data/models/auth_token_model.dart';
import 'package:hometasks/features/auth/data/models/user_model.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

/// Respuesta completa de login/register: usuario + token.
@freezed
class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required UserModel user,
    required AuthTokenModel token,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}
