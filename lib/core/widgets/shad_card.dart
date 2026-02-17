import 'package:flutter/material.dart';

import 'package:hometasks/core/theme/app_theme.dart';

/// Card inspirado en shadcn/ui Card.
/// Slots: header, content, footer — igual que shadcn.
class ShadCard extends StatelessWidget {
  const ShadCard({
    this.header,
    this.content,
    this.footer,
    this.padding,
    this.onTap,
    super.key,
  });

  /// Construye una card sin slots — padding completo uniforme.
  const ShadCard.simple({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    Key? key,
  }) : this(
          content: child,
          padding: padding,
          onTap: onTap,
          key: key,
          header: null,
          footer: null,
        );

  final Widget? header;
  final Widget? content;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final card = Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) _CardHeader(child: header!),
          if (content != null)
            Padding(
              padding: padding ?? AppSpacing.cardPadding,
              child: content,
            ),
          if (footer != null) ...[
            Divider(height: 1, color: cs.outline),
            _CardFooter(child: footer!),
          ],
        ],
      ),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: card,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x2l,
            AppSpacing.x2l,
            AppSpacing.x2l,
            AppSpacing.sm,
          ),
          child: child,
        ),
        Divider(height: 1, color: cs.outline),
      ],
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: child,
      );
}

/// Header semántico de una ShadCard.
class ShadCardHeader extends StatelessWidget {
  const ShadCardHeader({
    required this.title,
    this.description,
    super.key,
  });

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h4),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(description!, style: AppTextStyles.bodySM),
        ],
      ],
    );
  }
}
