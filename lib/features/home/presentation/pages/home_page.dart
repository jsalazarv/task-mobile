import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/routes/app_routes.dart';
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

  late List<TaskMock> _dayTasks;
  late List<TaskMock> _weekTasks;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = now;
    _weekStart = _mondayOf(now);
    _dayTasks = List.of(kDayTasks);
    _weekTasks = List.of(kWeekTasks);
  }

  DateTime _mondayOf(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _previousWeek() => setState(() {
        _weekStart = _weekStart.subtract(const Duration(days: 7));
      });

  void _nextWeek() => setState(() {
        _weekStart = _weekStart.add(const Duration(days: 7));
      });

  void _toggleTask(ViewMode mode, int index) {
    setState(() {
      final list = mode == ViewMode.day ? _dayTasks : _weekTasks;
      list[index] = list[index].copyWith(completed: !list[index].completed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) context.go(AppRoutes.login);
      },
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        return _HomeScaffold(
          user: user,
          selectedDay: _selectedDay,
          weekStart: _weekStart,
          viewMode: _viewMode,
          navIndex: _navIndex,
          dayTasks: _dayTasks,
          weekTasks: _weekTasks,
          onDaySelected: (day) => setState(() => _selectedDay = day),
          onPreviousWeek: _previousWeek,
          onNextWeek: _nextWeek,
          onViewModeChanged: (mode) => setState(() => _viewMode = mode),
          onToggleTask: _toggleTask,
          onNavTap: (index) {
            if (index == 2) {
              showCreateTaskSheet(context);
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
    required this.dayTasks,
    required this.weekTasks,
    required this.onDaySelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onViewModeChanged,
    required this.onToggleTask,
    required this.onNavTap,
  });

  final UserEntity? user;
  final DateTime selectedDay;
  final DateTime weekStart;
  final ViewMode viewMode;
  final int navIndex;
  final List<TaskMock> dayTasks;
  final List<TaskMock> weekTasks;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final ValueChanged<ViewMode> onViewModeChanged;
  final void Function(ViewMode mode, int index) onToggleTask;
  final ValueChanged<int> onNavTap;

  List<TaskMock> get _tasks => viewMode == ViewMode.day ? dayTasks : weekTasks;

  int get _completedCount => _tasks.where((t) => t.completed).length;

  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;

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
                  final pendingCount = tasks.where((t) => !t.completed).length;
                  final isLastTask =
                      !tasks[index].completed && pendingCount == 1;
                  return TaskCard(
                    task: tasks[index],
                    onToggle: () => onToggleTask(viewMode, index),
                    isLastTask: isLastTask,
                    onTap: () => showTaskDetailSheet(
                      context,
                      tasks[index],
                      () => onToggleTask(viewMode, index),
                      isLastTask: isLastTask,
                    ),
                  );
                },
                childCount: tasks.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x2l)),
          ],
        ),
      ),
    );
  }
}
