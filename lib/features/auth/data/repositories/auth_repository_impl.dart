import 'package:dartz/dartz.dart';
import 'package:hometasks/core/error/exceptions.dart';
import 'package:hometasks/core/error/failures.dart';
import 'package:hometasks/core/network/network_info.dart';
import 'package:hometasks/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:hometasks/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:hometasks/features/auth/domain/entities/auth_token_entity.dart';
import 'package:hometasks/features/auth/domain/entities/user_entity.dart';
import 'package:hometasks/features/auth/domain/failures/auth_failure.dart';
import 'package:hometasks/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final response = await _remote.login(email: email, password: password);

      await _local.saveSession(user: response.user, token: response.token);

      return Right(response.user.toEntity());
    } on AuthenticationException catch (e) {
      return Left(InvalidCredentialsFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final response = await _remote.register(
        name: name,
        email: email,
        password: password,
      );

      await _local.saveSession(user: response.user, token: response.token);

      return Right(response.user.toEntity());
    } on ServerException catch (e) {
      if (e.code == 'email_already_in_use') {
        return const Left(EmailAlreadyInUseFailure());
      }
      return Left(ServerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await Future.wait([
        _remote.logout(),
        _local.clearSession(),
      ]);
      return const Right(unit);
    } on AppException catch (e) {
      // Aunque falle el remote, limpiamos local para cerrar sesión localmente
      await _local.clearSession();
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await _local.getCachedUser();

      if (user == null) return const Left(NoSessionFailure());

      return Right(user.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthTokenEntity>> refreshToken() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final cachedToken = await _local.getCachedToken();

      if (cachedToken == null) return const Left(NoSessionFailure());

      final newToken =
          await _remote.refreshToken(cachedToken.refreshToken);

      // Persiste el nuevo token
      final user = await _local.getCachedUser();
      if (user != null) {
        await _local.saveSession(user: user, token: newToken);
      }

      return Right(newToken.toEntity());
    } on UnauthorizedException {
      await _local.clearSession();
      return const Left(SessionExpiredFailure());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<bool> get isAuthenticated => _local.hasSession;
}
