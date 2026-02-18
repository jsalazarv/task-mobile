import 'package:flutter/material.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';
import 'package:hometasks/features/home/presentation/widgets/xp_burst_overlay.dart';

// Borde sutil para tema oscuro glass.
Border _glassBorder(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? Border.all(color: AppColors.cardDarkBorder, width: 1)
      : Border.all(color: AppColors.border, width: 1);
}

class TaskCard extends StatefulWidget {
  const TaskCard({
    required this.task,
    required this.onToggle,
    required this.onTap,
    this.isLastTask = false,
    super.key,
  });

  final TaskMock task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final bool isLastTask;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  void _handleToggle() {
    if (!widget.task.completed) {
      showXpBurst(context, isLastTask: widget.isLastTask);
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: _CardContent(
        task: widget.task,
        onToggle: _handleToggle,
      ),
    );
  }
}

// ── Card content ─────────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.task,
    required this.onToggle,
  });

  final TaskMock task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.card,
        border: _glassBorder(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Checkbox(
            completed: task.completed,
            onTap: onToggle,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryLabel(category: task.category),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.completed
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                ),
                if (task.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                _MetaRow(task: task),
              ],
            ),
          ),
          // Tres puntos de acción
          Icon(
            Icons.more_vert,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ── Checkbox ──────────────────────────────────────────────────────────────────

class _Checkbox extends StatelessWidget {
  const _Checkbox({
    required this.completed,
    required this.onTap,
    super.key,
  });

  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          gradient: completed
              ? const LinearGradient(
                  colors: [AppColors.indigo500, AppColors.violet600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: completed ? null : Colors.transparent,
          shape: BoxShape.circle,
          border: completed
              ? null
              : Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.5,
                ),
          boxShadow: completed
              ? [
                  BoxShadow(
                    color: AppColors.indigo500.withOpacity(0.55),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: completed
              ? const Icon(
                  Icons.check,
                  key: ValueKey('check'),
                  size: 14,
                  color: AppColors.white,
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ),
    );
  }
}

// ── Sub-widgets de la card ────────────────────────────────────────────────────

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({required this.category});

  final TaskCategory category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(category.emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(
          category.labelUpper,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: category.foreground,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final assigneeName = task.assigneeId == null
        ? null
        : MemberService.instance.members
            .where((m) => m.id == task.assigneeId)
            .map((m) => m.displayName)
            .firstOrNull;

    return Row(
      children: [
        if (task.time != null) ...[
          Icon(Icons.access_time_outlined, size: 13, color: mutedColor),
          const SizedBox(width: 3),
          Text(
            task.time!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedColor,
                ),
          ),
        ],
        if (assigneeName != null) ...[
          const SizedBox(width: AppSpacing.md),
          Icon(Icons.person_outline, size: 13, color: mutedColor),
          const SizedBox(width: 3),
          Text(
            assigneeName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedColor,
                ),
          ),
        ],
      ],
    );
  }
}
