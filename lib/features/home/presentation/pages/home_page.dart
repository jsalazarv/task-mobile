import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/core/services/group_service.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/services/task_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_state.dart';
import 'package:hometasks/features/home/presentation/widgets/create_task_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:hometasks/features/home/presentation/pages/my_day_page.dart';
import 'package:hometasks/features/home/presentation/pages/summary_page.dart';
import 'package:hometasks/features/home/presentation/widgets/task_detail_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/home_header.dart';
import 'package:hometasks/features/home/presentation/widgets/task_card.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';
import 'package:hometasks/features/home/presentation/widgets/member_filter_row.dart';
import 'package:hometasks/features/home/presentation/widgets/view_mode_selector.dart';
import 'package:hometasks/features/home/presentation/widgets/week_calendar.dart';
import 'package:hometasks/features/home/presentation/widgets/weekly_progress_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedDay;
  late DateTime _weekStart;
  ViewMode _viewMode = ViewMode.day;
  int _navIndex = 0;
  String? _filterMemberId;
  String _lastGroupId = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = now;
    _weekStart = _mondayOf(now);
    TaskService.instance.tasksNotifier.addListener(_onTasksChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Limpia el filtro de miembro cuando el usuario cambia de grupo para
    // evitar que quede activo un ID que no pertenece al nuevo grupo.
    final currentGroupId =
        context.read<AppSettingsCubit>().state.activeGroupId ?? '';
    if (currentGroupId != _lastGroupId) {
      _lastGroupId = currentGroupId;
      if (_filterMemberId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _filterMemberId = null);
        });
      }
    }
  }

  @override
  void dispose() {
    TaskService.instance.tasksNotifier.removeListener(_onTasksChanged);
    super.dispose();
  }

  void _onTasksChanged() => setState(() {});

  DateTime _mondayOf(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  void _previousWeek() => setState(() {
    _weekStart = _weekStart.subtract(const Duration(days: 7));
  });

  void _nextWeek() => setState(() {
    _weekStart = _weekStart.add(const Duration(days: 7));
  });

  List<Task> get _currentTasks {
    final groupId = context.read<AppSettingsCubit>().state.activeGroupId ?? '';

    final base =
        _viewMode == ViewMode.day
            ? TaskService.instance.forGroupAndDay(groupId, _selectedDay)
            : TaskService.instance.forGroupAndWeek(groupId, _weekStart);

    final filter = _filterMemberId;
    if (filter == null) return base;
    return base.where((t) => t.assigneeId == filter).toList();
  }

  Future<void> _confirmDeleteTask(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Eliminar tarea'),
            content: Text('¿Eliminar "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'Eliminar',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) await TaskService.instance.remove(task.id);
  }

  @override
  Widget build(BuildContext context) {
    // watch para que el widget se reconstruya cuando cambie el grupo activo.
    final activeGroupId =
        context.watch<AppSettingsCubit>().state.activeGroupId ?? '';

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthUnauthenticated) {
          // Limpia todos los datos locales antes de redirigir al login,
          // para evitar que un segundo usuario vea datos del anterior.
          await TaskService.instance.clearAll();
          await MemberService.instance.clearAll();
          await GroupService.instance.clearAll();
          await context.read<AppSettingsCubit>().resetForLogout();
          if (context.mounted) context.go(AppRoutes.login);
        }
      },
      builder: (context, _) {
        // Al cambiar de grupo se limpia el filtro de miembro para evitar
        // que quede seleccionado un miembro que no pertenece al nuevo grupo.
        final tasks = _currentTasks;

        return _HomeScaffold(
          activeGroupId: activeGroupId,
          selectedDay: _selectedDay,
          weekStart: _weekStart,
          viewMode: _viewMode,
          navIndex: _navIndex,
          tasks: tasks,
          filterMemberId: _filterMemberId,
          onDaySelected: (day) => setState(() => _selectedDay = day),
          onPreviousWeek: _previousWeek,
          onNextWeek: _nextWeek,
          onViewModeChanged: (mode) => setState(() => _viewMode = mode),
          onFilterChanged: (id) => setState(() => _filterMemberId = id),
          onToggleTask: (task) => TaskService.instance.toggleCompleted(task.id),
          onDeleteTask: (task) => _confirmDeleteTask(context, task),
          onNavTap: (index) {
            if (index == 2) {
              showCreateTaskSheet(context, date: _selectedDay);
              return;
            }
            if (index == 4) {
              context.push(AppRoutes.settings);
              return;
            }
            setState(() => _navIndex = index);
          },
        );
      },
    );
  }
}

class _HomeScaffold extends StatelessWidget {
  const _HomeScaffold({
    required this.activeGroupId,
    required this.selectedDay,
    required this.weekStart,
    required this.viewMode,
    required this.navIndex,
    required this.tasks,
    required this.filterMemberId,
    required this.onDaySelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onViewModeChanged,
    required this.onFilterChanged,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onNavTap,
  });

  /// ID del grupo activo — usado como key del scroll para forzar rebuild
  /// completo cuando el usuario cambia de grupo, evitando cache visual.
  final String activeGroupId;
  final DateTime selectedDay;
  final DateTime weekStart;
  final ViewMode viewMode;
  final int navIndex;
  final List<Task> tasks;
  final String? filterMemberId;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final ValueChanged<ViewMode> onViewModeChanged;
  final ValueChanged<String?> onFilterChanged;
  final ValueChanged<Task> onToggleTask;
  final ValueChanged<Task> onDeleteTask;
  final ValueChanged<int> onNavTap;

  int get _completedCount => tasks.where((t) => t.completed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: HomeBottomNav(
        currentIndex: navIndex,
        onTap: onNavTap,
      ),
      body: SafeArea(
        child:
            navIndex == 3
                ? const SummaryPage()
                : navIndex == 0
                ? const MyDayPage()
                : CustomScrollView(
                  // La key fuerza un rebuild completo del scroll al cambiar
                  // de grupo, descartando cualquier estado visual cacheado.
                  key: ValueKey(activeGroupId),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const HomeHeader(),
                          const SizedBox(height: AppSpacing.lg),
                          WeekCalendar(
                            weekStart: weekStart,
                            selectedDay: selectedDay,
                            onDaySelected: onDaySelected,
                            onPreviousWeek: onPreviousWeek,
                            onNextWeek: onNextWeek,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ViewModeSelector(
                            selected: viewMode,
                            onChanged: onViewModeChanged,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          MemberFilterRow(
                            selectedMemberId: filterMemberId,
                            onFilterChanged: onFilterChanged,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          WeeklyProgressCard(
                            completed: _completedCount,
                            total: tasks.length,
                            viewMode: viewMode,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                    if (tasks.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyTasksState(
                          onAddTask:
                              () => showCreateTaskSheet(
                                context,
                                date: selectedDay,
                              ),
                        ),
                      )
                    else ...[
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final task = tasks[index];
                          final pendingCount =
                              tasks.where((t) => !t.completed).length;
                          final isLastTask =
                              !task.completed && pendingCount == 1;

                          return TaskCard(
                            task: task,
                            onToggle: () => onToggleTask(task),
                            isLastTask: isLastTask,
                            onTap:
                                () => showTaskDetailSheet(
                                  context,
                                  task,
                                  () => onToggleTask(task),
                                  onDelete: () => onDeleteTask(task),
                                  isLastTask: isLastTask,
                                ),
                          );
                        }, childCount: tasks.length),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.x2l),
                      ),
                    ],
                  ],
                ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyTasksState extends StatelessWidget {
  const _EmptyTasksState({required this.onAddTask});

  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2l,
        vertical: AppSpacing.x2l,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.indigo500.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.playlist_add_check_outlined,
              size: 40,
              color: AppColors.indigo400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Sin tareas para este día',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '¡Es un buen momento para planificar!\nAgrega la primera tarea del día.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.x2l),
          GestureDetector(
            onTap: onAddTask,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x2l,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.indigo500, AppColors.violet600],
                ),
                borderRadius: AppRadius.card,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.indigo500.withOpacity(0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 18, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Agregar tarea',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
