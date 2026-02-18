import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';
import 'package:hometasks/features/home/presentation/widgets/xp_burst_overlay.dart';

/// Muestra el bottom sheet de detalle de tarea.
/// [onToggle] se invoca cuando el usuario cambia el estado de completado.
/// [isLastTask] indica si es la última tarea pendiente de la lista.
void showTaskDetailSheet(
  BuildContext context,
  TaskMock task,
  VoidCallback onToggle, {
  bool isLastTask = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (_) => _BlurOverlay(
      child: _TaskDetailSheet(
        task: task,
        onToggle: onToggle,
        isLastTask: isLastTask,
      ),
    ),
  );
}

class _BlurOverlay extends StatelessWidget {
  const _BlurOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: child),
      ],
    );
  }
}

class _TaskDetailSheet extends StatelessWidget {
  const _TaskDetailSheet({
    required this.task,
    required this.onToggle,
    this.isLastTask = false,
  });

  final TaskMock task;
  final VoidCallback onToggle;
  final bool isLastTask;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.x2l,
          AppSpacing.x2l,
          AppSpacing.x2l,
          bottomSafe + AppSpacing.x2l,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailHeader(task: task),
            const SizedBox(height: AppSpacing.x2l),
            _TitleSection(task: task),
            const SizedBox(height: AppSpacing.lg),
            _ChipRow(task: task),
            const SizedBox(height: AppSpacing.lg),
            _StatusCard(task: task, l10n: l10n),
            const SizedBox(height: AppSpacing.x2l),
            _ToggleButton(
              completed: task.completed,
              l10n: l10n,
                onPressed: () {
                final wasCompleting = !task.completed;
                onToggle();
                Navigator.of(context).pop();
                if (wasCompleting) {
                  showXpBurst(context, isLastTask: isLastTask);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.task});

  final TaskMock task;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryIcon(category: task.category),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.category.labelUpper,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: task.category.foreground,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
              ),
              Text(
                l10n.taskDetailToday,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        _CloseButton(onTap: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});

  final TaskCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: category.background,
        borderRadius: AppRadius.card,
      ),
      alignment: Alignment.center,
      child: Text(category.emoji, style: const TextStyle(fontSize: 22)),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

// ── Título y descripción ────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.task});

  final TaskMock task;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                decoration:
                    task.completed ? TextDecoration.lineThrough : null,
                color: task.completed
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSurface,
              ),
        ),
        if (task.description != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.description_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Chips de hora y categoría ───────────────────────────────────────────────

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.task});

  final TaskMock task;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          icon: Icons.access_time_outlined,
          label: task.time,
        ),
        const SizedBox(width: AppSpacing.sm),
        _Chip(
          icon: Icons.label_outline,
          label: task.category.label,
          foregroundColor: task.category.foreground,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = foregroundColor ?? cs.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Status card ─────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.task, required this.l10n});

  final TaskMock task;
  final AppLocalizations l10n;

  static const _completedBg = Color(0xFFF0FDF4);
  static const _completedBgDark = Color(0xFF052E16);
  static const _completedFg = Color(0xFF15803D);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bg;
    final Color checkColor;
    final Color checkBorder;

    if (task.completed) {
      bg = isDark ? _completedBgDark : _completedBg;
      checkColor = _completedFg;
      checkBorder = _completedFg;
    } else {
      bg = cs.surfaceContainerHighest;
      checkColor = Colors.transparent;
      checkBorder = cs.outline;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          _StatusCircle(
            completed: task.completed,
            circleColor: checkColor,
            borderColor: checkBorder,
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.completed
                    ? l10n.taskDetailStatusCompleted
                    : l10n.taskDetailStatusPending,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: task.completed ? _completedFg : cs.onSurface,
                    ),
              ),
              Text(
                task.completed
                    ? l10n.taskDetailStatusCompletedSubtitle
                    : l10n.taskDetailStatusPendingSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: task.completed
                          ? _completedFg.withOpacity(0.75)
                          : cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({
    required this.completed,
    required this.circleColor,
    required this.borderColor,
  });

  final bool completed;
  final Color circleColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
        border: completed
            ? null
            : Border.all(color: borderColor, width: 1.5),
      ),
      child: completed
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}

// ── Botón CTA ───────────────────────────────────────────────────────────────

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.completed,
    required this.l10n,
    required this.onPressed,
  });

  final bool completed;
  final AppLocalizations l10n;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!completed) {
      return _PrimaryButton(
        label: l10n.taskDetailMarkCompleted,
        onPressed: onPressed,
      );
    }

    return SizedBox(
      height: 52,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: AppRadius.card,
          ),
          alignment: Alignment.center,
          child: Text(
            l10n.taskDetailMarkPending,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.indigo500, AppColors.violet600],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: AppRadius.card,
            boxShadow: [
              BoxShadow(
                color: AppColors.indigo500.withOpacity(0.55),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
          ),
        ),
      ),
    );
  }
}
