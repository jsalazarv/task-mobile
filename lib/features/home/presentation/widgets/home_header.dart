import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/l10n/generated/app_localizations.dart';
import 'package:hometasks/core/models/group.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/core/services/group_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(l10n),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                _GroupSelector(),
              ],
            ),
          ),
          const _NotificationBell(),
        ],
      ),
    );
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 19) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }
}

// ── Selector de grupo activo ──────────────────────────────────────────────────

class _GroupSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, settings) {
        return ValueListenableBuilder<List<Group>>(
          valueListenable: GroupService.instance.groupsNotifier,
          builder: (context, groups, _) {
            final activeGroup = groups.cast<Group?>().firstWhere(
              (g) => g?.id == settings.activeGroupId,
              orElse: () => groups.isNotEmpty ? groups.first : null,
            );

            if (activeGroup == null) {
              return GestureDetector(
                onTap: () => context.push(AppRoutes.groups),
                child: Text(
                  'Sin grupo activo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            if (groups.length == 1) {
              return Text(
                activeGroup.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              );
            }

            return GestureDetector(
              onTap: () => _showGroupPicker(context, groups, settings),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activeGroup.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGroupPicker(
    BuildContext context,
    List<Group> groups,
    AppSettingsState settings,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => _GroupPickerSheet(
            groups: groups,
            activeGroupId: settings.activeGroupId,
            onSelect: (group) async {
              Navigator.of(ctx).pop();
              await context.read<AppSettingsCubit>().setActiveGroup(group.id);
            },
            onManage: () {
              Navigator.of(ctx).pop();
              context.push(AppRoutes.groups);
            },
          ),
    );
  }
}

class _GroupPickerSheet extends StatelessWidget {
  const _GroupPickerSheet({
    required this.groups,
    required this.activeGroupId,
    required this.onSelect,
    required this.onManage,
  });

  final List<Group> groups;
  final String? activeGroupId;
  final ValueChanged<Group> onSelect;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.x2l,
          AppSpacing.lg,
          AppSpacing.x2l,
          bottomSafe + AppSpacing.x2l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Cambiar grupo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            ...groups.map((group) {
              final isActive = group.id == activeGroupId;
              return GestureDetector(
                onTap: () => onSelect(group),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient:
                        isActive
                            ? const LinearGradient(
                              colors: [
                                AppColors.indigo500,
                                AppColors.violet600,
                              ],
                            )
                            : null,
                    color: isActive ? null : cs.surfaceContainerHighest,
                    borderRadius: AppRadius.card,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        group.typeIcon,
                        size: 20,
                        color: isActive ? Colors.white : group.color,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          group.name,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : null,
                          ),
                        ),
                      ),
                      if (isActive)
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onManage,
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Gestionar grupos'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                side: const BorderSide(color: AppColors.indigo500),
                foregroundColor: AppColors.indigo400,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Campana de notificaciones ─────────────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_outlined, size: 22),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.destructive,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
