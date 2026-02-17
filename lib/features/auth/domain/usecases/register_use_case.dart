import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hometasks/core/error/failures.dart';
import 'package:hometasks/core/usecases/use_case.dart';
import 'package:hometasks/features/auth/domain/entities/user_entity.dart';
import 'package:hometasks/features/auth/domain/repositories/auth_repository.dart';
import 'package:hometasks/features/auth/domain/value_objects/email_value_object.dart';
import 'package:hometasks/features/auth/domain/value_objects/password_value_object.dart';

final class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'El nombre es requerido'));
    }

    final emailResult = EmailValueObject.create(params.email);
    if (emailResult.isLeft()) {
      return Left(emailResult.fold(id, (_) => const ValidationFailure(message: '')));
    }

    final passwordResult = PasswordValueObject.create(params.password);
    if (passwordResult.isLeft()) {
      return Left(passwordResult.fold(id, (_) => const ValidationFailure(message: '')));
    }

    return _repository.register(
      name: params.name.trim(),
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
  }
}

final class RegisterParams extends Equatable {
  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object> get props => [name, email, password];
}
