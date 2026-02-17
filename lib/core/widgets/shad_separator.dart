import 'package:flutter/material.dart';

import 'package:hometasks/core/theme/app_theme.dart';

/// Separator con label opcional, inspirado en shadcn/ui Separator.
class ShadSeparator extends StatelessWidget {
  const ShadSeparator({this.label, super.key});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (label == null) {
      return Divider(height: 1, color: cs.outline);
    }

    return Row(
      children: [
        Expanded(child: Divider(color: cs.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(label!, style: AppTextStyles.labelSM),
        ),
        Expanded(child: Divider(color: cs.outline)),
      ],
    );
  }
}
