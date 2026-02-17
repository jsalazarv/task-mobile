import 'package:dartz/dartz.dart';
import 'package:hometasks/core/error/failures.dart';
import 'package:hometasks/core/usecases/use_case.dart';
import 'package:hometasks/features/auth/domain/repositories/auth_repository.dart';

final class LogoutUseCase implements NoParamsUseCase<Unit> {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call() => _repository.logout();
}
