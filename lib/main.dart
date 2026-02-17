import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hometasks/core/config/env/dev_env.dart';
import 'package:hometasks/core/config/env/env_config.dart';
import 'package:hometasks/core/di/injection.dart';
import 'package:hometasks/core/routes/app_router.dart';
import 'package:hometasks/core/storage/hive_service.dart';
import 'package:hometasks/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.initialize(DevEnv());

  await configureDependencies();

  final hiveService = getIt<HiveService>();
  await hiveService.init();

  runApp(const HomeTasks());
}

class HomeTasks extends StatelessWidget {
  const HomeTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HomeTasks',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,

      // Routing
      routerConfig: appRouter,

      // i18n
      locale: const Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
