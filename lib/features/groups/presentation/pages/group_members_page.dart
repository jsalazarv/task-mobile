import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hometasks/core/models/family_member.dart';
import 'package:hometasks/core/models/group.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/create_member_sheet.dart';

/// Pantalla para gestionar los miembros de un grupo específico.
class GroupMembersPage extends StatelessWidget {
  const GroupMembersPage({required this.group, super.key});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              group: group,
              onBack: () => Navigator.of(context).pop(),
              onAdd: () => showCreateMemberSheet(context, groupId: group.id),
            ),
            Expanded(
              child: ValueListenableBuilder<List<FamilyMember>>(
                valueListenable: MemberService.instance.membersNotifier,
                builder: (context, allMembers, _) {
                  final members =
                      allMembers.where((m) => m.groupId == group.id).toList();

                  if (members.isEmpty) {
                    return _EmptyState(
                      onAdd:
                          () =>
                              showCreateMemberSheet(context, groupId: group.id),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: members.length,
                    separatorBuilder:
                        (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder:
                        (context, index) => _MemberCard(
                          member: members[index],
                          onEdit:
                              () =>
                                  showEditMemberSheet(context, members[index]),
                          onDelete:
                              () => _confirmDelete(context, members[index]),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Eliminar miembro'),
            content: Text('¿Eliminar a ${member.name} del grupo?'),
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

    if (confirmed == true && context.mounted) {
      await MemberService.instance.remove(member.id);
    }
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.group,
    required this.onBack,
    required this.onAdd,
  });

  final Group group;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Miembros',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  group.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
            const Icon(
              Icons.person_add_outlined,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'Agregar',
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

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  final FamilyMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(member.id),
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
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: AppRadius.card,
            border:
                isDark
                    ? Border.all(color: AppColors.cardDarkBorder, width: 1)
                    : null,
            boxShadow:
                isDark
                    ? null
                    : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
          ),
          child: Row(
            children: [
              _Avatar(member: member),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (member.nickname != null)
                      Text(
                        member.nickname!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              _LevelBadge(level: member.level),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.member});

  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    const size = 46.0;
    final imagePath = member.avatarImagePath;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: member.avatarColor.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        border: Border.all(color: member.avatarColor, width: 2),
        image:
            imagePath != null
                ? DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      alignment: Alignment.center,
      child:
          imagePath == null
              ? Text(
                member.initial,
                style: TextStyle(
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w800,
                  color: member.avatarColor,
                ),
              )
              : null,
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.xpGoldLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.xpGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 2),
          Text(
            'Nv.$level',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.xpGold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
              'Sin miembros',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Agrega personas que participarán en las tareas de este grupo.',
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
                  'Agregar primer miembro',
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
