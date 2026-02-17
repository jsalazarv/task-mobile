import 'package:dartz/dartz.dart';
import 'package:hometasks/core/error/failures.dart';

/// Contrato base para todos los use cases con parámetros.
abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Contrato base para use cases sin parámetros.
abstract interface class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Sentinel para use cases que no reciben parámetros.
final class NoParams {
  const NoParams();
}
