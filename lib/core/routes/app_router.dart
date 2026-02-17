import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_state.dart';
import 'package:hometasks/features/auth/presentation/pages/home_page.dart';
import 'package:hometasks/features/auth/presentation/pages/login_page.dart';
import 'package:hometasks/features/auth/presentation/pages/register_page.dart';

/// Adaptador que convierte el stream del AuthBloc en un [Listenable]
/// para que GoRouter se refresque ante cambios de estado.
class AuthBlocListenable extends ChangeNotifier {
  AuthBlocListenable(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Construye el router con acceso al [AuthBloc] ya provisto en el árbol.
GoRouter buildAppRouter(AuthBloc authBloc) {
  final listenable = AuthBlocListenable(authBloc);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: listenable,
    redirect: (context, state) => _authGuard(authBloc, state),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, __) => const HomePage(),
      ),
    ],
  );
}

/// Guard de autenticación — única fuente de verdad para redirecciones.
String? _authGuard(AuthBloc authBloc, GoRouterState state) {
  final authState = authBloc.state;
  final isOnAuth = state.matchedLocation == AppRoutes.login ||
      state.matchedLocation == AppRoutes.register;

  if (authState is AuthInitial || authState is AuthLoading) return null;

  if (authState is AuthAuthenticated && isOnAuth) return AppRoutes.home;

  if (authState is AuthUnauthenticated && !isOnAuth) return AppRoutes.login;

  return null;
}


