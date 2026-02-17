import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hometasks/core/config/env/dev_env.dart';
import 'package:hometasks/core/config/env/env_config.dart';
import 'package:hometasks/core/di/injection.dart';
import 'package:hometasks/core/routes/app_router.dart';
import 'package:hometasks/core/storage/hive_service.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.initialize(DevEnv());

  await configureDependencies();

  final hiveService = getIt<HiveService>();
  await hiveService.init();

  final authBloc = getIt<AuthBloc>();
  authBloc.add(const AuthCheckSessionRequested());

  runApp(HomeTasks(authBloc: authBloc));
}

class HomeTasks extends StatefulWidget {
  const HomeTasks({required this.authBloc, super.key});

  final AuthBloc authBloc;

  @override
  State<HomeTasks> createState() => _HomeTasksState();
}

class _HomeTasksState extends State<HomeTasks> {
  late final _router = buildAppRouter(widget.authBloc);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.authBloc,
      child: MaterialApp.router(
        title: 'HomeTasks',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,

        // i18n
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Routing
        routerConfig: _router,
      ),
    );
  }
}
