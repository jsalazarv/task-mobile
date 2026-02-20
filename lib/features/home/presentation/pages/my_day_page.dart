import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/services/task_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_state.dart';
import 'package:hometasks/features/home/presentation/widgets/create_task_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/task_card.dart';
import 'package:hometasks/features/home/presentation/widgets/task_detail_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';

// ── Frases motivacionales ─────────────────────────────────────────────────────

const _quotes = [
  'La constancia es el camino más corto al éxito.',
  'Pequeños pasos todos los días crean grandes resultados.',
  'Un hogar ordenado es una mente tranquila.',
  'El secreto está en empezar.',
  'Haz hoy lo que tu yo futuro te agradecerá.',
  'La disciplina es elegir lo que quieres más sobre lo que quieres ahora.',
  'No esperes el momento perfecto, toma el momento y hazlo perfecto.',
  'El orden en casa trae orden en la vida.',
  'Cada tarea completada es una victoria pequeña.',
  'El esfuerzo de hoy es el descanso de mañana.',
  'La organización no es un talento, es un hábito.',
  'Haz una cosa a la vez y hazla bien.',
  'El progreso, no la perfección, es lo que importa.',
  'Un día productivo empieza con intención.',
  'Lo que se hace con amor se hace bien.',
  'El mejor momento para actuar es siempre ahora.',
  'Cuida tu espacio y tu espacio te cuidará.',
  'La rutina es la madre de la maestría.',
  'Celebra cada tarea terminada, por pequeña que sea.',
  'El orden es la forma visible del amor.',
  'Donde hay voluntad, hay camino.',
  'Una casa limpia es un hogar feliz.',
  'Empieza donde estás, usa lo que tienes, haz lo que puedes.',
  'La perseverancia convierte lo imposible en posible.',
  'Cada día es una nueva oportunidad de mejorar.',
];

String _quoteOfTheDay() {
  final dayOfYear =
      DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  return _quotes[dayOfYear % _quotes.length];
}

// ── Página ────────────────────────────────────────────────────────────────────

class MyDayPage extends StatefulWidget {
  const MyDayPage({super.key});

  @override
  State<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  final _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    TaskService.instance.tasksNotifier.addListener(_onTasksChanged);
  }

  @override
  void dispose() {
    TaskService.instance.tasksNotifier.removeListener(_onTasksChanged);
    super.dispose();
  }

  void _onTasksChanged() => setState(() {});

  String? _ownerMemberId() {
    final authState = context.read<AuthBloc>().state;
    final groupId = context.read<AppSettingsCubit>().state.activeGroupId;
    if (authState is! AuthAuthenticated || groupId == null || groupId.isEmpty) {
      return null;
    }
    return '${authState.user.id}_$groupId';
  }

  String _userName() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return '';
    final groupId = context.read<AppSettingsCubit>().state.activeGroupId ?? '';
    final memberId = '${authState.user.id}_$groupId';
    final member =
        MemberService.instance.members
            .where((m) => m.id == memberId)
            .firstOrNull;
    return member?.displayName ?? authState.user.name;
  }

  List<Task> _myTasksToday() {
    final groupId = context.read<AppSettingsCubit>().state.activeGroupId ?? '';
    final memberId = _ownerMemberId();
    final allToday = TaskService.instance.forGroupAndDay(groupId, _today);

    // Muestra las tareas asignadas al usuario Y las tareas sin asignar del grupo,
    // ya que el dueño puede tomar cualquier tarea pendiente.
    final mine =
        memberId != null
            ? allToday
                .where((t) => t.assigneeId == memberId || t.assigneeId == null)
                .toList()
            : allToday;

    // Pendientes primero ordenadas por sortOrder, luego completadas
    final pending =
        mine.where((t) => !t.completed).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final done =
        mine.where((t) => t.completed).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return [...pending, ...done];
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final tasks = _myTasksToday();
    // Solo se puede reordenar dentro de las pendientes
    final pending = tasks.where((t) => !t.completed).toList();
    if (oldIndex >= pending.length) return;

    if (newIndex > oldIndex) newIndex--;
    final item = pending.removeAt(oldIndex);
    // Clamp para no salirse de las pendientes
    final clampedIndex = newIndex.clamp(0, pending.length);
    pending.insert(clampedIndex, item);

    final orderedIds = [
      ...pending.map((t) => t.id),
      ...tasks.where((t) => t.completed).map((t) => t.id),
    ];
    await TaskService.instance.reorderDay(orderedIds);
  }

  Future<void> _confirmDelete(Task task) async {
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
    context.watch<AppSettingsCubit>();

    final tasks = _myTasksToday();
    final pending = tasks.where((t) => !t.completed).length;
    final total = tasks.length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _DayBanner(
            userName: _userName(),
            date: _today,
            quote: _quoteOfTheDay(),
            completed: total - pending,
            total: total,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.x2l,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis tareas de hoy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Arrastra para definir el orden en que quieres completarlas.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (tasks.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              onAdd: () => showCreateTaskSheet(context, date: _today),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
            sliver: _TaskReorderableList(
              tasks: tasks,
              pendingCount: pending,
              onReorder: _onReorder,
              onToggle: (task) => TaskService.instance.toggleCompleted(task.id),
              onTap: (task) {
                final isLastTask = !task.completed && pending == 1;
                showTaskDetailSheet(
                  context,
                  task,
                  () => TaskService.instance.toggleCompleted(task.id),
                  onDelete: () => _confirmDelete(task),
                  isLastTask: isLastTask,
                );
              },
            ),
          ),
      ],
    );
  }
}

// ── Banner ────────────────────────────────────────────────────────────────────

class _DayBanner extends StatefulWidget {
  const _DayBanner({
    required this.userName,
    required this.date,
    required this.quote,
    required this.completed,
    required this.total,
  });

  final String userName;
  final DateTime date;
  final String quote;
  final int completed;
  final int total;

  @override
  State<_DayBanner> createState() => _DayBannerState();
}

class _DayBannerState extends State<_DayBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blobCtrl;

  @override
  void initState() {
    super.initState();
    _blobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobCtrl.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = widget.date.hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String get _dateLabel {
    const weekDays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    const months = [
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
    final d = widget.date;
    return '${weekDays[d.weekday - 1]}, ${d.day} de ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.indigo700, AppColors.violet600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo600.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Blob decorativo 1
          Positioned(
            right: -30,
            top: -20,
            child: AnimatedBuilder(
              animation: _blobCtrl,
              builder:
                  (_, __) => Transform.translate(
                    offset: Offset(0, -10 + 20 * _blobCtrl.value),
                    child: Transform.scale(
                      scale: 0.92 + 0.16 * _blobCtrl.value,
                      child: const _Blob(size: 140, opacity: 0.10),
                    ),
                  ),
            ),
          ),
          // Blob decorativo 2
          Positioned(
            left: -20,
            bottom: -30,
            child: AnimatedBuilder(
              animation: _blobCtrl,
              builder: (_, __) {
                final inv = 1.0 - _blobCtrl.value;
                return Transform.translate(
                  offset: Offset(0, -8 + 16 * inv),
                  child: Transform.scale(
                    scale: 0.90 + 0.18 * inv,
                    child: const _Blob(size: 110, opacity: 0.08),
                  ),
                );
              },
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.x2l,
              AppSpacing.lg,
              AppSpacing.x2l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$_greeting${widget.userName.isNotEmpty ? ', ${widget.userName}' : ''}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.waving_hand,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _dateLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Separador
                Container(
                  height: 1,
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Frase motivacional
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: AppColors.white.withValues(alpha: 0.6),
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.quote,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.total > 0) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _ProgressRow(
                    completed: widget.completed,
                    total: widget.total,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Barra de progreso del banner ──────────────────────────────────────────────

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final allDone = completed == total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              allDone ? '¡Todo completado! 🎉' : '$completed de $total tareas',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color:
                    allDone
                        ? AppColors.xpGold
                        : AppColors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.badge,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder:
                (_, value, __) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    allDone ? AppColors.xpGold : AppColors.white,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

// ── Lista reordenable ─────────────────────────────────────────────────────────

class _TaskReorderableList extends StatelessWidget {
  const _TaskReorderableList({
    required this.tasks,
    required this.pendingCount,
    required this.onReorder,
    required this.onToggle,
    required this.onTap,
  });

  final List<Task> tasks;
  final int pendingCount;
  final ReorderCallback onReorder;
  final ValueChanged<Task> onToggle;
  final ValueChanged<Task> onTap;

  @override
  Widget build(BuildContext context) {
    final pending = tasks.where((t) => !t.completed).toList();
    final done = tasks.where((t) => t.completed).toList();
    final cs = Theme.of(context).colorScheme;

    return SliverList(
      delegate: SliverChildListDelegate([
        if (pending.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pending.length,
            onReorder: onReorder,
            proxyDecorator:
                (child, index, animation) => Material(
                  elevation: 6,
                  color: Colors.transparent,
                  shadowColor: AppColors.indigo500.withValues(alpha: 0.3),
                  borderRadius: AppRadius.card,
                  child: child,
                ),
            itemBuilder: (context, index) {
              final task = pending[index];
              final isLastTask = pendingCount == 1;
              return _DraggableTaskCard(
                key: ValueKey(task.id),
                task: task,
                isLastTask: isLastTask,
                onToggle: () => onToggle(task),
                onTap: () => onTap(task),
                cs: cs,
              );
            },
          ),
        if (done.isNotEmpty) ...[
          if (pending.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 14,
                    color: AppColors.categoryGardenFg,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Completadas',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.categoryGardenFg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ...done.map(
            (task) => TaskCard(
              key: ValueKey(task.id),
              task: task,
              isLastTask: false,
              onToggle: () => onToggle(task),
              onTap: () => onTap(task),
            ),
          ),
        ],
      ]),
    );
  }
}

// ── TaskCard con drag handle para pendientes ──────────────────────────────────

/// Envuelve [TaskCard] añadiendo un drag handle a la izquierda.
/// Solo se usa para tareas pendientes en la vista reordenable de "Mi día".
class _DraggableTaskCard extends StatelessWidget {
  const _DraggableTaskCard({
    required this.task,
    required this.isLastTask,
    required this.onToggle,
    required this.onTap,
    required this.cs,
    super.key,
  });

  final Task task;
  final bool isLastTask;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: Icon(
            Icons.drag_handle_rounded,
            size: 20,
            color: cs.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
        Expanded(
          child: TaskCard(
            task: task,
            isLastTask: isLastTask,
            onToggle: onToggle,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

// ── Blob decorativo ───────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BlobPainter(opacity: opacity),
    );
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: opacity)
          ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final path =
        Path()
          ..moveTo(w * 0.5, 0)
          ..cubicTo(w * 0.85, 0, w, h * 0.25, w, h * 0.5)
          ..cubicTo(w, h * 0.82, w * 0.78, h, w * 0.5, h)
          ..cubicTo(w * 0.18, h, 0, h * 0.75, 0, h * 0.5)
          ..cubicTo(0, h * 0.22, w * 0.18, 0, w * 0.5, 0)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.opacity != opacity;
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

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
              color: AppColors.indigo500.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wb_sunny_outlined,
              size: 40,
              color: AppColors.indigo400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tu día está libre',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No tienes tareas asignadas para hoy.\n¡Agrégalas y planifica tu jornada!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.x2l),
          GestureDetector(
            onTap: onAdd,
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
                    color: AppColors.indigo500.withValues(alpha: 0.45),
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
