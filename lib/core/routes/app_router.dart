import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_state.dart';
import 'package:hometasks/features/auth/presentation/pages/login_page.dart';
import 'package:hometasks/features/auth/presentation/pages/register_page.dart';
import 'package:hometasks/features/home/presentation/pages/home_page.dart';
import 'package:hometasks/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:hometasks/features/settings/presentation/pages/members_page.dart';
import 'package:hometasks/features/settings/presentation/pages/settings_page.dart';

/// Adaptador que convierte el stream del AuthBloc en un [Listenable]
/// para que GoRouter se refresque ante cambios de estado.
class _AuthAndSettingsListenable extends ChangeNotifier {
  _AuthAndSettingsListenable(
    AuthBloc authBloc,
    AppSettingsCubit settingsCubit,
  ) {
    _authSub = authBloc.stream.listen((_) => notifyListeners());
    _settingsSub = settingsCubit.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _authSub;
  late final StreamSubscription<AppSettingsState> _settingsSub;

  @override
  void dispose() {
    _authSub.cancel();
    _settingsSub.cancel();
    super.dispose();
  }
}

/// Construye el router con acceso al [AuthBloc] y [AppSettingsCubit].
GoRouter buildAppRouter(AuthBloc authBloc, AppSettingsCubit settingsCubit) {
  final listenable = _AuthAndSettingsListenable(authBloc, settingsCubit);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: listenable,
    redirect: (context, state) =>
        _guard(authBloc, settingsCubit, state),
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
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (_, __) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.members,
        name: 'members',
        builder: (_, __) => const MembersPage(),
      ),
    ],
  );
}

/// Guard unificado: autenticación + onboarding.
String? _guard(
  AuthBloc authBloc,
  AppSettingsCubit settingsCubit,
  GoRouterState state,
) {
  final authState = authBloc.state;
  final location = state.matchedLocation;

  final isOnAuth = location == AppRoutes.login ||
      location == AppRoutes.register;
  final isOnOnboarding = location == AppRoutes.onboarding;

  // Mientras el auth está resolviendo, no redirigir.
  if (authState is AuthInitial || authState is AuthLoading) return null;

  // Usuario no autenticado → login (excepto si ya está en auth).
  if (authState is AuthUnauthenticated && !isOnAuth) return AppRoutes.login;

  // Usuario autenticado en pantallas de auth → siguiente paso.
  if (authState is AuthAuthenticated && isOnAuth) {
    return settingsCubit.state.onboardingComplete
        ? AppRoutes.home
        : AppRoutes.onboarding;
  }

  // Usuario autenticado sin onboarding → forzar onboarding.
  if (authState is AuthAuthenticated &&
      !settingsCubit.state.onboardingComplete &&
      !isOnOnboarding) {
    return AppRoutes.onboarding;
  }

  return null;
}
