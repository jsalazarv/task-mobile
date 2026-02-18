import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';

/// Muestra el selector de responsable y retorna el [FamilyMember] elegido.
Future<FamilyMember?> showAssigneePickerSheet(BuildContext context) {
  return showModalBottomSheet<FamilyMember>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (_) => const _BlurOverlay(child: _AssigneePickerSheet()),
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

class _AssigneePickerSheet extends StatelessWidget {
  const _AssigneePickerSheet();

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHeader(onClose: () => Navigator.of(context).pop()),
            const SizedBox(height: AppSpacing.lg),
            ValueListenableBuilder<List<FamilyMember>>(
              valueListenable: MemberService.instance.membersNotifier,
              builder: (context, members, _) {
                if (members.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2l),
                    child: Text(
                      'No hay miembros. Agrega uno desde Ajustes.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) => _MemberTile(
                    member: members[index],
                    onTap: () => Navigator.of(context).pop(members[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Seleccionar responsable',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 18),
          ),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.onTap});

  final FamilyMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.card,
          border: isDark
              ? Border.all(color: AppColors.cardDarkBorder, width: 1)
              : Border.all(
                  color: cs.surfaceContainerHighest,
                  width: 1,
                ),
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
            Icon(
              Icons.chevron_right,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
          ],
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
    const size = 42.0;
    final imagePath = member.avatarImagePath;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: member.avatarColor.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(color: member.avatarColor, width: 2),
        image: imagePath != null
            ? DecorationImage(
                image: FileImage(File(imagePath)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: imagePath == null
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
