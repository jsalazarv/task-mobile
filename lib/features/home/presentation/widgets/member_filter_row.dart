import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/core/utils/sound_service.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';

/// Fila de chips horizontales para filtrar tareas por miembro.
///
/// Muestra un chip "Todos" y uno por cada miembro registrado.
/// Notifica cambios a través de [onFilterChanged] con el id del miembro
/// seleccionado, o `null` cuando se elige "Todos".
class MemberFilterRow extends StatelessWidget {
  const MemberFilterRow({
    super.key,
    required this.selectedMemberId,
    required this.onFilterChanged,
  });

  final String? selectedMemberId;
  final ValueChanged<String?> onFilterChanged;

  void _select(BuildContext context, String? id) {
    final soundEnabled = context.read<AppSettingsCubit>().state.soundEnabled;
    SoundService.instance.playSwitch(enabled: soundEnabled);
    onFilterChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    final activeGroupId =
        context.watch<AppSettingsCubit>().state.activeGroupId ?? '';

    return ValueListenableBuilder<List<FamilyMember>>(
      valueListenable: MemberService.instance.membersNotifier,
      builder: (context, allMembers, _) {
        final members =
            allMembers.where((m) => m.groupId == activeGroupId).toList();

        if (members.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              _AllChip(
                isSelected: selectedMemberId == null,
                onTap: () => _select(context, null),
              ),
              ...members.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: _MemberChip(
                    member: m,
                    isSelected: selectedMemberId == m.id,
                    onTap: () => _select(context, m.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Chips internos ────────────────────────────────────────────────────────────

Color _inactiveBorderColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.cardDarkBorder : AppColors.border;
}

class _AllChip extends StatelessWidget {
  const _AllChip({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [AppColors.indigo500, AppColors.violet600],
                  )
                  : null,
          color: isSelected ? null : cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color:
                isSelected ? Colors.transparent : _inactiveBorderColor(context),
          ),
        ),
        child: Text(
          'Todos',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isSelected ? Colors.white : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  final FamilyMember member;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? member.avatarColor.withOpacity(0.18) : cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color:
                isSelected ? member.avatarColor : _inactiveBorderColor(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MiniAvatar(member: member, isSelected: isSelected),
            const SizedBox(width: 6),
            Text(
              member.displayName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? member.avatarColor : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.member, required this.isSelected});

  final FamilyMember member;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const size = 20.0;
    final imagePath = member.avatarImagePath;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: member.avatarColor.withOpacity(isSelected ? 0.35 : 0.2),
        shape: BoxShape.circle,
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
                  fontSize: size * 0.5,
                  fontWeight: FontWeight.w800,
                  color: member.avatarColor,
                ),
              )
              : null,
    );
  }
}
