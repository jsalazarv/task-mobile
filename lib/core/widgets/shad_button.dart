import 'package:flutter/material.dart';

import 'package:hometasks/core/theme/app_theme.dart';

enum ShadButtonVariant { primary, secondary, outline, ghost, destructive, link }

enum ShadButtonSize { sm, md, lg, icon }

/// Botón inspirado en shadcn/ui Button.
/// El proyecto "posee" este componente — modifícalo directamente.
class ShadButton extends StatelessWidget {
  const ShadButton({
    required this.child,
    this.onPressed,
    this.variant = ShadButtonVariant.primary,
    this.size = ShadButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final ShadButtonVariant variant;
  final ShadButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return AnimatedOpacity(
      opacity: isDisabled ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: _height,
        child: _buildButton(context, isDisabled),
      ),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    final content = _buildContent(context);

    if (variant == ShadButtonVariant.primary) {
      return _PrimaryGradientButton(
        onPressed: isDisabled ? null : onPressed,
        height: _height,
        padding: _padding,
        textStyle: _textStyle,
        child: content,
      );
    }

    final style = _resolveStyle(context);

    return switch (variant) {
      ShadButtonVariant.outline || ShadButtonVariant.ghost => OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: style,
        child: content,
      ),
      ShadButtonVariant.link => TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: style,
        child: content,
      ),
      _ => ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: style,
        child: content,
      ),
    };
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _foregroundColor(context),
        ),
      );
    }

    if (leadingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [leadingIcon!, const SizedBox(width: AppSpacing.sm), child],
      );
    }

    return child;
  }

  double get _height => switch (size) {
    ShadButtonSize.sm => 36,
    ShadButtonSize.md => 44,
    ShadButtonSize.lg => 52,
    ShadButtonSize.icon => 44,
  };

  EdgeInsets get _padding => switch (size) {
    ShadButtonSize.sm => const EdgeInsets.symmetric(horizontal: 12),
    ShadButtonSize.md => const EdgeInsets.symmetric(horizontal: 16),
    ShadButtonSize.lg => const EdgeInsets.symmetric(horizontal: 24),
    ShadButtonSize.icon => const EdgeInsets.all(10),
  };

  TextStyle get _textStyle => switch (size) {
    ShadButtonSize.sm => AppTextStyles.label,
    ShadButtonSize.lg => AppTextStyles.bodyLG.copyWith(
      fontWeight: FontWeight.w500,
    ),
    _ => AppTextStyles.button,
  };

  Color _foregroundColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (variant) {
      ShadButtonVariant.primary => cs.onPrimary,
      ShadButtonVariant.secondary => cs.onSecondary,
      ShadButtonVariant.destructive => AppColors.destructiveForeground,
      _ => cs.onSurface,
    };
  }

  ButtonStyle _resolveStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = ButtonStyle(
      padding: WidgetStatePropertyAll(_padding),
      textStyle: WidgetStatePropertyAll(_textStyle),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
      minimumSize: const WidgetStatePropertyAll(Size.zero),
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
    );

    return switch (variant) {
      ShadButtonVariant.primary => base.copyWith(
        backgroundColor: WidgetStatePropertyAll(cs.primary),
        foregroundColor: WidgetStatePropertyAll(cs.onPrimary),
      ),
      ShadButtonVariant.secondary => base.copyWith(
        backgroundColor: WidgetStatePropertyAll(cs.secondary),
        foregroundColor: WidgetStatePropertyAll(cs.onSecondary),
      ),
      ShadButtonVariant.destructive => base.copyWith(
        backgroundColor: const WidgetStatePropertyAll(AppColors.destructive),
        foregroundColor: const WidgetStatePropertyAll(
          AppColors.destructiveForeground,
        ),
      ),
      ShadButtonVariant.outline => base.copyWith(
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(cs.onSurface),
        side: WidgetStatePropertyAll(BorderSide(color: cs.outline)),
      ),
      ShadButtonVariant.ghost => base.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.hovered)
                  ? cs.surfaceContainerHighest
                  : Colors.transparent,
        ),
        foregroundColor: WidgetStatePropertyAll(cs.onSurface),
        side: const WidgetStatePropertyAll(BorderSide.none),
      ),
      ShadButtonVariant.link => base.copyWith(
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(cs.primary),
        textStyle: WidgetStatePropertyAll(
          _textStyle.copyWith(decoration: TextDecoration.underline),
        ),
      ),
    };
  }
}

// ── Botón primario con degradado indigo → violet ──────────────────────────────

class _PrimaryGradientButton extends StatelessWidget {
  const _PrimaryGradientButton({
    required this.child,
    required this.height,
    required this.padding,
    required this.textStyle,
    this.onPressed,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double height;
  final EdgeInsets padding;
  final TextStyle textStyle;

  static const _gradient = LinearGradient(
    colors: [AppColors.indigo500, AppColors.violet600],
  );

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.button,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.button,
        child: Ink(
          decoration: BoxDecoration(
            gradient: isDisabled ? null : _gradient,
            color:
                isDisabled
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : null,
            borderRadius: AppRadius.button,
          ),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: padding,
              child: Center(
                child: DefaultTextStyle(
                  style: textStyle.copyWith(
                    color:
                        isDisabled
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : AppColors.white,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color:
                          isDisabled
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : AppColors.white,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
