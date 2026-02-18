import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/core/utils/sound_service.dart';

enum ViewMode { day, week }

/// Selector de vista Día / Semana.
/// Pill redondeada: contenedor gris + tab activo con fondo blanco/surface
/// a la misma altura, con padding interno y sombra sutil.
class ViewModeSelector extends StatelessWidget {
  const ViewModeSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ViewMode selected;
  final ValueChanged<ViewMode> onChanged;

  static const double _height       = 46;
  static const double _padding      = 2;
  static const double _outerRadius  = 12;
  static const double _innerRadius  = 10;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: _height,
        padding: const EdgeInsets.all(_padding),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(_outerRadius),
        ),
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Tab(
                  label: l10n.viewDay,
                  icon: Icons.calendar_today_outlined,
                  isSelected: selected == ViewMode.day,
                  onTap: () {
                    if (selected == ViewMode.day) return;
                    SoundService.instance.playSwitch(
                      enabled: context.read<AppSettingsCubit>().state.soundEnabled,
                    );
                    onChanged(ViewMode.day);
                  },
                ),
                _Tab(
                  label: l10n.viewWeek,
                  icon: Icons.calendar_view_week_outlined,
                  isSelected: selected == ViewMode.week,
                  onTap: () {
                    if (selected == ViewMode.week) return;
                    SoundService.instance.playSwitch(
                      enabled: context.read<AppSettingsCubit>().state.soundEnabled,
                    );
                    onChanged(ViewMode.week);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = isSelected ? cs.onSurface : cs.onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(ViewModeSelector._innerRadius),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: textColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
