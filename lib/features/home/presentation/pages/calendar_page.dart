import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hometasks/core/services/task_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/create_task_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/task_card.dart';
import 'package:hometasks/features/home/presentation/widgets/task_detail_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, this.onDayChanged});

  /// Notifica al padre el día seleccionado para que el FAB del bottom nav
  /// pueda abrir el sheet de creación con la fecha correcta.
  final ValueChanged<DateTime>? onDayChanged;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _displayMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
    _selectedDay = now;
    TaskService.instance.tasksNotifier.addListener(_onTasksChanged);
  }

  @override
  void dispose() {
    TaskService.instance.tasksNotifier.removeListener(_onTasksChanged);
    super.dispose();
  }

  void _onTasksChanged() => setState(() {});

  void _previousMonth() => setState(() {
    _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
  });

  void _nextMonth() => setState(() {
    _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
  });

  String get _activeGroupId =>
      context.read<AppSettingsCubit>().state.activeGroupId ?? '';

  List<Task> get _tasksForSelectedDay =>
      TaskService.instance.forGroupAndDay(_activeGroupId, _selectedDay);

  Map<DateTime, _DayStatus> _buildDayStatusMap() {
    final groupId = _activeGroupId;
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final lastDay = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    final weekTasks = TaskService.instance.tasks.where((t) {
      if (t.groupId != groupId) return false;
      final d = _dateOnly(t.date);
      return !d.isBefore(firstDay) && !d.isAfter(lastDay);
    });

    final Map<DateTime, _DayStatus> map = {};
    for (final task in weekTasks) {
      final key = _dateOnly(task.date);
      final current = map[key];
      if (current == null) {
        map[key] = task.completed ? _DayStatus.allDone : _DayStatus.pending;
      } else if (current == _DayStatus.allDone && !task.completed) {
        map[key] = _DayStatus.pending;
      }
    }
    return map;
  }

  Future<void> _confirmDeleteTask(Task task) async {
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

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    // Reacciona a cambios del grupo activo.
    context.watch<AppSettingsCubit>();

    final statusMap = _buildDayStatusMap();
    final tasks = _tasksForSelectedDay;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              _MonthHeader(
                displayMonth: _displayMonth,
                onPrevious: _previousMonth,
                onNext: _nextMonth,
              ),
              const SizedBox(height: AppSpacing.lg),
              _MonthGrid(
                displayMonth: _displayMonth,
                selectedDay: _selectedDay,
                statusMap: statusMap,
                onDaySelected: (day) {
                  setState(() => _selectedDay = day);
                  widget.onDayChanged?.call(day);
                },
              ),
              const SizedBox(height: AppSpacing.x2l),
              _DayTasksHeader(
                selectedDay: _selectedDay,
                taskCount: tasks.length,
                onAddTask:
                    () => showCreateTaskSheet(context, date: _selectedDay),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
        if (tasks.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyDayState(
              onAddTask: () => showCreateTaskSheet(context, date: _selectedDay),
            ),
          )
        else ...[
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final task = tasks[index];
              final pendingCount = tasks.where((t) => !t.completed).length;
              final isLastTask = !task.completed && pendingCount == 1;

              return TaskCard(
                task: task,
                onToggle: () => TaskService.instance.toggleCompleted(task.id),
                isLastTask: isLastTask,
                onTap:
                    () => showTaskDetailSheet(
                      context,
                      task,
                      () => TaskService.instance.toggleCompleted(task.id),
                      onDelete: () => _confirmDeleteTask(task),
                      isLastTask: isLastTask,
                    ),
              );
            }, childCount: tasks.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x2l)),
        ],
      ],
    );
  }
}

// ── Header del mes ────────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.displayMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime displayMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  static const _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = '${_monthNames[displayMonth.month - 1]} ${displayMonth.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavArrow(icon: Icons.chevron_left, onTap: onPrevious),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          _NavArrow(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark ? AppColors.glassDarkBg : cs.surfaceContainerHighest,
          borderRadius: AppRadius.button,
          border:
              isDark
                  ? Border.all(color: AppColors.cardDarkBorder, width: 1)
                  : null,
        ),
        child: Icon(icon, size: 18, color: cs.onSurface),
      ),
    );
  }
}

// ── Grid mensual ─────────────────────────────────────────────────────────────

enum _DayStatus { pending, allDone }

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.displayMonth,
    required this.selectedDay,
    required this.statusMap,
    required this.onDaySelected,
  });

  final DateTime displayMonth;
  final DateTime selectedDay;
  final Map<DateTime, _DayStatus> statusMap;
  final ValueChanged<DateTime> onDaySelected;

  static const _weekLabels = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime day) => _isSameDay(day, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    // weekday: 1=lun ... 7=dom
    final leadingBlanks = firstOfMonth.weekday - 1;
    final daysInMonth =
        DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
    final totalCells = leadingBlanks + daysInMonth;
    // Redondear a múltiplo de 7 para llenar la última fila.
    final gridCells = (totalCells / 7).ceil() * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          // Cabecera de días de la semana
          Row(
            children:
                _weekLabels
                    .map(
                      (label) => Expanded(
                        child: Center(
                          child: Text(
                            label,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Grilla de celdas
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
            ),
            itemCount: gridCells,
            itemBuilder: (context, index) {
              final dayNumber = index - leadingBlanks + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }
              final day = DateTime(
                displayMonth.year,
                displayMonth.month,
                dayNumber,
              );
              final key = DateTime(day.year, day.month, day.day);
              final status = statusMap[key];
              final isSelected = _isSameDay(day, selectedDay);
              final isToday = _isToday(day);

              return _DayCell(
                day: dayNumber,
                isSelected: isSelected,
                isToday: isToday,
                status: status,
                onTap: () => onDaySelected(day),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Celda de día ──────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
    this.status,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final _DayStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: _dayDecoration(cs),
            child: Center(
              child: Text(
                '$day',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      isSelected
                          ? AppColors.white
                          : isToday
                          ? cs.primary
                          : cs.onSurface,
                  fontWeight:
                      isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          _StatusDot(status: status, isSelected: isSelected),
        ],
      ),
    );
  }

  BoxDecoration _dayDecoration(ColorScheme cs) {
    if (isSelected) {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.indigo600, AppColors.violet600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x73504BE9), // indigo600 ~45%
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      );
    }
    if (isToday) {
      return BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary, width: 1.5),
      );
    }
    return const BoxDecoration(shape: BoxShape.circle);
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status, required this.isSelected});

  final _DayStatus? status;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox(height: 6);

    final color =
        isSelected
            ? AppColors.white.withOpacity(0.8)
            : status == _DayStatus.allDone
            ? AppColors.categoryGardenFg
            : AppColors.indigo400;

    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Cabecera de la sección de tareas del día ──────────────────────────────────

class _DayTasksHeader extends StatelessWidget {
  const _DayTasksHeader({
    required this.selectedDay,
    required this.taskCount,
    required this.onAddTask,
  });

  final DateTime selectedDay;
  final int taskCount;
  final VoidCallback onAddTask;

  static const _weekDays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  static const _months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  String get _dayLabel {
    final now = DateTime.now();
    final isToday =
        selectedDay.year == now.year &&
        selectedDay.month == now.month &&
        selectedDay.day == now.day;
    final isTomorrow =
        selectedDay.difference(DateTime(now.year, now.month, now.day)).inDays ==
        1;

    if (isToday) return 'Hoy';
    if (isTomorrow) return 'Mañana';

    final weekDay = _weekDays[selectedDay.weekday - 1];
    final month = _months[selectedDay.month - 1];
    return '$weekDay ${selectedDay.day} de $month';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dayLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                if (taskCount > 0)
                  Text(
                    '$taskCount ${taskCount == 1 ? 'tarea' : 'tareas'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAddTask,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.indigo500, AppColors.violet600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x736366F1), // indigo500 ~45%
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyDayState extends StatelessWidget {
  const _EmptyDayState({required this.onAddTask});

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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.indigo500.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available_outlined,
              size: 36,
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
            'Toca el botón + para agregar\nuna tarea a este día.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
