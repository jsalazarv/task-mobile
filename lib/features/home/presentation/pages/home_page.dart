import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/core/services/task_service.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/auth/domain/entities/user_entity.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_state.dart';
import 'package:hometasks/features/home/presentation/widgets/create_task_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:hometasks/features/home/presentation/pages/summary_page.dart';
import 'package:hometasks/features/home/presentation/widgets/task_detail_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/home_header.dart';
import 'package:hometasks/features/home/presentation/widgets/task_card.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';
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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = now;
    _weekStart = _mondayOf(now);
    // Escucha cambios del servicio para reconstruir la UI.
    TaskService.instance.tasksNotifier.addListener(_onTasksChanged);
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

  List<Task> get _currentTasks => _viewMode == ViewMode.day
      ? TaskService.instance.forDay(_selectedDay)
      : TaskService.instance.forWeek(_weekStart);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) context.go(AppRoutes.login);
      },
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final tasks = _currentTasks;

        return _HomeScaffold(
          user: user,
          selectedDay: _selectedDay,
          weekStart: _weekStart,
          viewMode: _viewMode,
          navIndex: _navIndex,
          tasks: tasks,
          onDaySelected: (day) => setState(() => _selectedDay = day),
          onPreviousWeek: _previousWeek,
          onNextWeek: _nextWeek,
          onViewModeChanged: (mode) => setState(() => _viewMode = mode),
          onToggleTask: (task) => TaskService.instance.toggleCompleted(task.id),
          onDeleteTask: (task) => TaskService.instance.remove(task.id),
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
    required this.user,
    required this.selectedDay,
    required this.weekStart,
    required this.viewMode,
    required this.navIndex,
    required this.tasks,
    required this.onDaySelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onViewModeChanged,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onNavTap,
  });

  final UserEntity? user;
  final DateTime selectedDay;
  final DateTime weekStart;
  final ViewMode viewMode;
  final int navIndex;
  final List<Task> tasks;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final ValueChanged<ViewMode> onViewModeChanged;
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
        child: navIndex == 3
            ? const SummaryPage()
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HomeHeader(userName: user?.name ?? 'Mi Hogar'),
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
                        const SizedBox(height: AppSpacing.lg),
                        WeeklyProgressCard(
                          completed: _completedCount,
                          total: tasks.length,
                          viewMode: viewMode,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = tasks[index];
                        final pendingCount =
                            tasks.where((t) => !t.completed).length;
                        final isLastTask =
                            !task.completed && pendingCount == 1;

                        return TaskCard(
                          task: task,
                          onToggle: () => onToggleTask(task),
                          isLastTask: isLastTask,
                          onTap: () => showTaskDetailSheet(
                            context,
                            task,
                            () => onToggleTask(task),
                            onDelete: () => onDeleteTask(task),
                            isLastTask: isLastTask,
                          ),
                        );
                      },
                      childCount: tasks.length,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.x2l),
                  ),
                ],
              ),
      ),
    );
  }
}
