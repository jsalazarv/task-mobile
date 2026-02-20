import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_state.dart';
import 'package:hometasks/features/auth/presentation/pages/login_page.dart';
import 'package:hometasks/features/auth/presentation/pages/register_page.dart';
import 'package:hometasks/features/groups/presentation/pages/create_group_page.dart';
import 'package:hometasks/features/groups/presentation/pages/groups_page.dart';
import 'package:hometasks/features/home/presentation/pages/home_page.dart';
import 'package:hometasks/features/onboarding/presentation/pages/onboarding_page.dart';
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
    initialLocation: AppRoutes.splash,
    refreshListenable: listenable,
    redirect: (context, state) => _guard(authBloc, settingsCubit, state),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const _SplashScreen(),
      ),
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
        path: AppRoutes.groups,
        name: 'groups',
        builder: (_, __) => const GroupsPage(),
      ),
      GoRoute(
        path: AppRoutes.createGroup,
        name: 'createGroup',
        builder: (_, __) => const CreateGroupPage(),
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
  final settings = settingsCubit.state;
  final location = state.matchedLocation;

  // Mientras auth o settings están resolviendo, esperar en /splash.
  if (authState is AuthInitial || authState is AuthLoading) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  // Settings aún tiene valores por defecto (no han cargado de disco):
  // esperamos en /splash hasta que el cubit emita tras load().
  if (!settings.loaded) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final isOnAuth =
      location == AppRoutes.login || location == AppRoutes.register;
  final isOnOnboarding = location == AppRoutes.onboarding;
  final isOnSplash = location == AppRoutes.splash;

  // Una vez resuelto, salir del splash.
  if (isOnSplash) {
    if (authState is AuthUnauthenticated) return AppRoutes.login;
    if (authState is AuthAuthenticated) {
      return settings.onboardingComplete
          ? AppRoutes.home
          : AppRoutes.onboarding;
    }
  }

  // Usuario no autenticado → login (excepto si ya está en auth).
  if (authState is AuthUnauthenticated && !isOnAuth) return AppRoutes.login;

  // Usuario autenticado en pantallas de auth → siguiente paso.
  if (authState is AuthAuthenticated && isOnAuth) {
    return settings.onboardingComplete ? AppRoutes.home : AppRoutes.onboarding;
  }

  // Usuario autenticado sin onboarding → forzar onboarding.
  if (authState is AuthAuthenticated &&
      !settings.onboardingComplete &&
      !isOnOnboarding) {
    return AppRoutes.onboarding;
  }

  return null;
}

/// Pantalla de carga mostrada mientras auth y settings inicializan.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
