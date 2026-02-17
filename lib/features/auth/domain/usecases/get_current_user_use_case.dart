import 'package:dartz/dartz.dart';
import 'package:hometasks/core/error/failures.dart';
import 'package:hometasks/core/usecases/use_case.dart';
import 'package:hometasks/features/auth/domain/entities/user_entity.dart';
import 'package:hometasks/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
final class GetCurrentUserUseCase implements NoParamsUseCase<UserEntity> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call() => _repository.getCurrentUser();
}
