import 'package:flutter/material.dart';
import 'package:hometasks/l10n/generated/app_localizations.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({
    required this.weekStart,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    super.key,
  });

  final DateTime weekStart;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    final l10n         = AppLocalizations.of(context)!;
    final weekDayLabels = _weekDayLabels(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          _MonthNavigator(
            weekStart: weekStart,
            onPrevious: onPreviousWeek,
            onNext: onNextWeek,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day        = weekStart.add(Duration(days: i));
              final isSelected = _isSameDay(day, selectedDay);
              return _DayCell(
                label: weekDayLabels[i],
                day: day.day,
                isSelected: isSelected,
                onTap: () => onDaySelected(day),
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static List<String> _weekDayLabels(AppLocalizations l10n) {
    if (l10n.localeName == 'en') {
      return ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    }
    return ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  }
}

// ── Navegador de mes ──────────────────────────────────────────────────────────

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.weekStart,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime weekStart;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final months = _monthNames(l10n);
    final label  = '${months[weekStart.month - 1]} ${weekStart.year}';
    final cs     = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavArrow(icon: Icons.chevron_left, onTap: onPrevious),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
        ),
        _NavArrow(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }

  static List<String> _monthNames(AppLocalizations l10n) => [
        l10n.monthJanuary,   l10n.monthFebruary, l10n.monthMarch,
        l10n.monthApril,     l10n.monthMay,      l10n.monthJune,
        l10n.monthJuly,      l10n.monthAugust,   l10n.monthSeptember,
        l10n.monthOctober,   l10n.monthNovember, l10n.monthDecember,
      ];
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs     = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.glassDarkBg
              : cs.surfaceContainerHighest,
          borderRadius: AppRadius.button,
          border: isDark
              ? Border.all(color: AppColors.cardDarkBorder, width: 1)
              : null,
        ),
        child: Icon(icon, size: 18, color: cs.onSurface),
      ),
    );
  }
}

// ── Celda de día ──────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: isSelected
                ? BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.indigo600, AppColors.violet600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.indigo600.withOpacity(0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  )
                : const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
            child: Center(
              child: Text(
                '$day',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isSelected ? AppColors.white : cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
