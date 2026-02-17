import 'package:dartz/dartz.dart';
import 'package:hometasks/core/error/failures.dart';
import 'package:hometasks/core/usecases/use_case.dart';
import 'package:hometasks/features/auth/domain/entities/auth_token_entity.dart';
import 'package:hometasks/features/auth/domain/repositories/auth_repository.dart';

final class RefreshTokenUseCase implements NoParamsUseCase<AuthTokenEntity> {
  const RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthTokenEntity>> call() => _repository.refreshToken();
}
