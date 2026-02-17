import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/routes/app_routes.dart';

/// Placeholder pages — serán reemplazadas en las fases de features.
class _LoginPage extends StatelessWidget {
  const _LoginPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Login — Phase 9')));
}

class _RegisterPage extends StatelessWidget {
  const _RegisterPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Register — Phase 9')));
}

class _HomePage extends StatelessWidget {
  const _HomePage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home — Phase 9')));
}

/// Única fuente de verdad para la navegación de la app.
///
/// Para activar el redirect de autenticación, inyecta el estado del
/// auth BLoC en [_authRedirect] cuando esté disponible (Phase 9).
final appRouter = GoRouter(
  initialLocation: AppRoutes.login,

  redirect: _authRedirect,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (_, __) => const _LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (_, __) => const _RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (_, __) => const _HomePage(),
    ),
  ],
);

/// Guard de autenticación.
/// Devuelve la ruta de redirección o null si se permite el acceso.
String? _authRedirect(BuildContext context, GoRouterState state) {
  // TODO(phase-9): leer estado real del AuthBloc e implementar lógica.
  return null;
}
