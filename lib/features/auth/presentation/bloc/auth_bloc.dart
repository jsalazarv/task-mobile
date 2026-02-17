import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hometasks/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:hometasks/features/auth/domain/usecases/login_use_case.dart';
import 'package:hometasks/features/auth/domain/usecases/logout_use_case.dart';
import 'package:hometasks/features/auth/domain/usecases/register_use_case.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_event.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_state.dart';
import 'package:injectable/injectable.dart';

@injectable
final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _login = loginUseCase,
        _register = registerUseCase,
        _logout = logoutUseCase,
        _getCurrentUser = getCurrentUserUseCase,
        super(const AuthInitial()) {
    on<AuthCheckSessionRequested>(_onCheckSession);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;

  Future<void> _onCheckSession(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _getCurrentUser();

    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSubmitting());

    final result = await _login(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSubmitting());

    final result = await _register(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSubmitting());

    final result = await _logout();

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
