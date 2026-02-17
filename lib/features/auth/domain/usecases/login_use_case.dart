import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hometasks/core/error/failures.dart';
import 'package:hometasks/core/usecases/use_case.dart';
import 'package:hometasks/features/auth/domain/entities/user_entity.dart';
import 'package:hometasks/features/auth/domain/repositories/auth_repository.dart';
import 'package:hometasks/features/auth/domain/value_objects/email_value_object.dart';
import 'package:hometasks/features/auth/domain/value_objects/password_value_object.dart';

final class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    final emailResult = EmailValueObject.create(params.email);
    final passwordResult = PasswordValueObject.create(params.password);

    // Retorna el primer error de validación encontrado
    if (emailResult.isLeft()) {
      return Left(emailResult.fold(id, (_) => const ValidationFailure(message: '')));
    }
    if (passwordResult.isLeft()) {
      return Left(passwordResult.fold(id, (_) => const ValidationFailure(message: '')));
    }

    return _repository.login(
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
  }
}

final class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}
