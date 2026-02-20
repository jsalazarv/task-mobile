import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/models/group.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/core/services/group_service.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/services/task_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/groups/presentation/pages/create_group_page.dart';
import 'package:hometasks/features/groups/presentation/pages/group_members_page.dart';

/// Pantalla que lista todos los grupos del usuario y permite seleccionar
/// el grupo activo, editarlo, gestionar sus miembros o eliminarlo.
class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _GroupsHeader(
              onBack: () => Navigator.of(context).pop(),
              onAdd: () => context.push(AppRoutes.createGroup),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Group>>(
                valueListenable: GroupService.instance.groupsNotifier,
                builder: (context, groups, _) {
                  if (groups.isEmpty) {
                    return _EmptyState(
                      onAdd: () => context.push(AppRoutes.createGroup),
                    );
                  }

                  return BlocBuilder<AppSettingsCubit, AppSettingsState>(
                    builder: (context, settings) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.lg,
                        ),
                        itemCount: groups.length,
                        separatorBuilder:
                            (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          final isActive = settings.activeGroupId == group.id;
                          return _GroupCard(
                            group: group,
                            isActive: isActive,
                            onSelect: () => _selectGroup(context, group),
                            onEdit: () => _editGroup(context, group),
                            onMembers: () => _openMembers(context, group),
                            onDelete:
                                () => _confirmDelete(context, group, settings),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectGroup(BuildContext context, Group group) async {
    await context.read<AppSettingsCubit>().setActiveGroup(group.id);
    if (!context.mounted) return;
    context.go(AppRoutes.home);
  }

  void _editGroup(BuildContext context, Group group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => BlocProvider.value(
              value: context.read<AppSettingsCubit>(),
              child: EditGroupPage(group: group),
            ),
      ),
    );
  }

  void _openMembers(BuildContext context, Group group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GroupMembersPage(group: group)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Group group,
    AppSettingsState settings,
  ) async {
    if (GroupService.instance.groups.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes eliminar el único grupo existente.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Eliminar grupo'),
            content: Text(
              '¿Eliminar "${group.name}"?\nSe eliminarán también sus tareas y miembros.',
            ),
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

    if (confirmed != true || !context.mounted) return;

    await GroupService.instance.remove(group.id);

    final membersToRemove =
        MemberService.instance.forGroup(group.id).map((m) => m.id).toList();
    for (final id in membersToRemove) {
      await MemberService.instance.remove(id);
    }

    final tasksToRemove =
        TaskService.instance.tasks
            .where((t) => t.groupId == group.id)
            .map((t) => t.id)
            .toList();
    for (final id in tasksToRemove) {
      await TaskService.instance.remove(id);
    }

    if (settings.activeGroupId == group.id && context.mounted) {
      final remaining = GroupService.instance.groups;
      if (remaining.isNotEmpty) {
        await context.read<AppSettingsCubit>().setActiveGroup(
          remaining.first.id,
        );
      }
    }
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _GroupsHeader extends StatelessWidget {
  const _GroupsHeader({required this.onBack, required this.onAdd});

  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
          Expanded(
            child: Text(
              'Mis grupos',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _AddButton(onTap: onAdd),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.indigo500, AppColors.violet600],
          ),
          borderRadius: AppRadius.button,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              'Nuevo',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.isActive,
    required this.onSelect,
    required this.onEdit,
    required this.onMembers,
    required this.onDelete,
  });

  final Group group;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onMembers;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(group.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.destructive.withValues(alpha: 0.15),
          borderRadius: AppRadius.card,
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.destructive),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient:
              isActive
                  ? const LinearGradient(
                    colors: [AppColors.indigo500, AppColors.violet600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isActive ? null : cs.surface,
          borderRadius: AppRadius.card,
          border:
              isDark && !isActive
                  ? Border.all(color: AppColors.cardDarkBorder, width: 1)
                  : null,
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: AppColors.indigo500.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : isDark
                  ? null
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
        ),
        child: Column(
          children: [
            // ── Fila principal: tap para seleccionar ────────────────────
            GestureDetector(
              onTap: onSelect,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? Colors.white.withValues(alpha: 0.2)
                                : group.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          group.typeIcon,
                          size: 22,
                          color: isActive ? Colors.white : group.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isActive ? Colors.white : null,
                            ),
                          ),
                          Text(
                            group.type.label,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  isActive
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),

            // ── Fila de acciones ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionChip(
                    icon: Icons.group_outlined,
                    label: 'Miembros',
                    isActive: isActive,
                    onTap: onMembers,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ActionChip(
                    icon: Icons.edit_outlined,
                    label: 'Editar',
                    isActive: isActive,
                    onTap: onEdit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color:
              isActive
                  ? Colors.white.withValues(alpha: 0.18)
                  : cs.surfaceContainerHighest,
          borderRadius: AppRadius.button,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive ? Colors.white : cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_add_outlined,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sin grupos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Crea tu primer grupo para organizar tareas con otras personas.',
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
                ),
                child: Text(
                  'Crear primer grupo',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
