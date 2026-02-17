import 'package:flutter/material.dart';

import 'package:hometasks/core/theme/app_theme.dart';

enum ShadBadgeVariant { primary, secondary, outline, destructive }

/// Badge inspirado en shadcn/ui Badge.
class ShadBadge extends StatelessWidget {
  const ShadBadge({
    required this.label,
    this.variant = ShadBadgeVariant.primary,
    super.key,
  });

  final String label;
  final ShadBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (bg, fg, border) = switch (variant) {
      ShadBadgeVariant.primary     => (cs.primary, cs.onPrimary, Colors.transparent),
      ShadBadgeVariant.secondary   => (cs.secondary, cs.onSecondary, Colors.transparent),
      ShadBadgeVariant.destructive => (AppColors.destructive, AppColors.destructiveForeground, Colors.transparent),
      ShadBadgeVariant.outline     => (Colors.transparent, cs.onSurface, cs.outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.badge,
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSM.copyWith(color: fg),
      ),
    );
  }
}
