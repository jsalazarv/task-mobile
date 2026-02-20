import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hometasks/core/config/env/dev_env.dart';
import 'package:hometasks/core/config/env/env_config.dart';
import 'package:hometasks/core/di/injection.dart';
import 'package:hometasks/core/routes/app_router.dart';
import 'package:hometasks/core/services/group_service.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/services/task_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/storage/hive_service.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_event.dart';
import 'package:hometasks/l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.initialize(DevEnv());
  await configureDependencies();

  final hiveService = getIt<HiveService>();
  await hiveService.init();

  await Future.wait([
    GroupService.instance.load(),
    MemberService.instance.load(),
    TaskService.instance.load(),
  ]);

  MemberService.instance.tasksProvider = () => TaskService.instance.tasks;

  // Cargar settings antes de runApp para evitar race conditions en el router.
  final settingsCubit = AppSettingsCubit();
  await settingsCubit.load();
  await _migrateLegacyDataIfNeeded(settingsCubit);

  final authBloc = getIt<AuthBloc>()..add(const AuthCheckSessionRequested());

  runApp(HomeTasks(authBloc: authBloc, settingsCubit: settingsCubit));
}

/// Migra datos anteriores al sistema de grupos asignando un grupo legacy
/// a todos los miembros y tareas que tengan [groupId] vacío.
Future<void> _migrateLegacyDataIfNeeded(AppSettingsCubit cubit) async {
  final settings = cubit.state;

  final hasMembersWithoutGroup = MemberService.instance.members.any(
    (m) => m.groupId.isEmpty,
  );
  final hasTasksWithoutGroup = TaskService.instance.tasks.any(
    (t) => t.groupId.isEmpty,
  );

  if (!hasMembersWithoutGroup && !hasTasksWithoutGroup) {
    if (settings.activeGroupId == null &&
        GroupService.instance.groups.isNotEmpty) {
      await cubit.setActiveGroup(GroupService.instance.groups.first.id);
    }
    return;
  }

  var legacyGroup = GroupService.instance.findById('legacy-home-group');
  legacyGroup ??= await GroupService.instance.createLegacyGroup(
    settings.homeName,
  );

  for (final member
      in MemberService.instance.members
          .where((m) => m.groupId.isEmpty)
          .toList()) {
    await MemberService.instance.update(
      member.copyWith(groupId: legacyGroup.id),
    );
  }

  for (final task
      in TaskService.instance.tasks.where((t) => t.groupId.isEmpty).toList()) {
    await TaskService.instance.update(task.copyWith(groupId: legacyGroup.id));
  }

  if (settings.activeGroupId == null) {
    await cubit.setActiveGroup(legacyGroup.id);
  }
}

class HomeTasks extends StatefulWidget {
  const HomeTasks({
    required this.authBloc,
    required this.settingsCubit,
    super.key,
  });

  final AuthBloc authBloc;
  final AppSettingsCubit settingsCubit;

  @override
  State<HomeTasks> createState() => _HomeTasksState();
}

class _HomeTasksState extends State<HomeTasks> {
  late final _router = buildAppRouter(widget.authBloc, widget.settingsCubit);

  @override
  void dispose() {
    widget.settingsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authBloc),
        BlocProvider.value(value: widget.settingsCubit),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            title: 'HomeTasks',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.withPrimary(
              settings.effectivePrimaryColor,
              brightness: Brightness.light,
            ),
            darkTheme: AppTheme.withPrimary(
              settings.effectivePrimaryColor,
              brightness: Brightness.dark,
            ),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
