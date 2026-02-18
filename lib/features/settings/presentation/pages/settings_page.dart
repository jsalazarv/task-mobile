import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/core/utils/sound_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, settings) {
        final cubit = context.read<AppSettingsCubit>();
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _SettingsHeader(onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    children: [
                      _SectionLabel(label: 'FAMILIA'),
                      const SizedBox(height: AppSpacing.sm),
                      _SettingsCard(
                        children: [
                          _LinkRow(
                            icon: Icons.group_outlined,
                            title: 'Miembros de la familia',
                            subtitle: 'Gestiona quiénes participan en las tareas',
                            onTap: () => context.push(AppRoutes.members),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.x2l),

                      _SectionLabel(label: l10n.settingsSectionPreferences),
                      const SizedBox(height: AppSpacing.sm),
                      _SettingsCard(
                        children: [
                          _LanguageRow(
                             selected: settings.locale.languageCode.toUpperCase(),
                             selectedLabel: settings.locale.languageCode == 'es'
                                 ? l10n.settingsLanguageEs
                                 : l10n.settingsLanguageEn,
                             onChanged: (lang) {
                               SoundService.instance.playSwitch(
                                 enabled: settings.soundEnabled,
                               );
                               cubit.setLocale(Locale(lang.toLowerCase()));
                             },
                           ),
                          _Divider(),
                          _ToggleRow(
                             icon: Icons.light_mode_outlined,
                             title: l10n.settingsTheme,
                             subtitle: settings.themeMode == ThemeMode.dark
                                 ? l10n.settingsThemeDark
                                 : l10n.settingsThemeLight,
                             value: settings.themeMode == ThemeMode.dark,
                             onChanged: (isDark) {
                               SoundService.instance.playSwitch(
                                 enabled: settings.soundEnabled,
                               );
                               cubit.setThemeMode(
                                 isDark ? ThemeMode.dark : ThemeMode.light,
                               );
                             },
                           ),
                           _Divider(),
                           _ToggleRow(
                             icon: Icons.volume_up_outlined,
                             title: l10n.settingsSounds,
                             subtitle: settings.soundEnabled
                                 ? l10n.settingsSoundsOn
                                 : l10n.settingsSoundsOff,
                             value: settings.soundEnabled,
                             onChanged: (enabled) {
                               SoundService.instance.playSwitch(enabled: true);
                               cubit.setSoundEnabled(enabled);
                             },
                           ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.x2l),

                      _SectionLabel(label: l10n.settingsSectionAbout),
                      const SizedBox(height: AppSpacing.sm),
                      _SettingsCard(
                        children: [
                          _LinkRow(
                            icon: Icons.email_outlined,
                            title: l10n.settingsContact,
                            subtitle: l10n.settingsContactSubtitle,
                            onTap: () {},
                          ),
                          _Divider(),
                          _LinkRow(
                            icon: Icons.favorite_outline,
                            title: l10n.settingsFollow,
                            subtitle: l10n.settingsFollowSubtitle,
                            onTap: () {},
                          ),
                          _Divider(),
                          _LinkRow(
                            icon: Icons.star_outline_rounded,
                            title: l10n.settingsRate,
                            subtitle: l10n.settingsRateSubtitle,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.x2l),

                      _SectionLabel(label: l10n.settingsSectionLegal),
                      const SizedBox(height: AppSpacing.sm),
                      _SettingsCard(
                        children: [
                          _LinkRow(
                            icon: Icons.description_outlined,
                            title: l10n.settingsTerms,
                            onTap: () {},
                          ),
                          _Divider(),
                          _LinkRow(
                            icon: Icons.shield_outlined,
                            title: l10n.settingsPrivacy,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.x2l),

                      Center(
                        child: Text(
                          l10n.settingsVersion,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Widgets internos ─────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onBack});

  final VoidCallback onBack;

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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          Text(
            AppLocalizations.of(context)!.settingsTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: AppSpacing.lg + 36 + AppSpacing.md,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}

class _SettingsIconBadge extends StatelessWidget {
  const _SettingsIconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.button,
      ),
      child: Icon(icon, size: 18, color: cs.primary),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.selected,
    required this.selectedLabel,
    required this.onChanged,
  });

  final String selected;
  final String selectedLabel;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const _SettingsIconBadge(icon: Icons.language_outlined),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguage,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  selectedLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          _LanguageToggle(selected: selected, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  static const double _height      = 34;
  static const double _padding     = 2;
  static const double _outerRadius = 10;
  static const double _innerRadius = 8;
  static const double _tabWidth    = 44;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: _height,
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_outerRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: ['ES', 'EN'].map((lang) {
          final isSelected = lang == selected;
          return GestureDetector(
            onTap: () => onChanged(lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: _tabWidth,
              decoration: BoxDecoration(
                color: isSelected ? cs.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(_innerRadius),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  lang,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _SettingsIconBadge(icon: icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            _SettingsIconBadge(icon: icon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
