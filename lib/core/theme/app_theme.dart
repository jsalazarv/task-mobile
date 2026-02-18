import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_radius.dart';
import 'package:hometasks/core/theme/app_text_styles.dart';

export 'app_colors.dart';
export 'app_radius.dart';
export 'app_spacing.dart';
export 'app_text_styles.dart';

/// Genera el [ThemeData] de Material 3 con los tokens de shadcn/ui.
abstract final class AppTheme {
  static ThemeData get light => _build(brightness: Brightness.light);
  static ThemeData get dark  => _build(brightness: Brightness.dark);

  /// Genera un tema con color primario personalizado.
  static ThemeData withPrimary(Color primaryColor, {required Brightness brightness}) =>
      _build(brightness: brightness, customPrimary: primaryColor);

  static ThemeData _build({
    required Brightness brightness,
    Color? customPrimary,
  }) {
    final isDark = brightness == Brightness.dark;

    final bg              = isDark ? AppColors.backgroundDark       : AppColors.background;
    final fg              = isDark ? AppColors.foregroundDark        : AppColors.foreground;
    final cardColor       = isDark ? AppColors.cardDark              : AppColors.card;
    final borderCol       = isDark ? AppColors.borderDark            : AppColors.border;
    final mutedCol        = isDark ? AppColors.mutedDark             : AppColors.muted;
    final mutedFg         = isDark ? AppColors.mutedForegroundDark   : AppColors.mutedForeground;
    // En dark usamos el fondo como scaffoldBg (mismo que bg), sin el warm off-white claro.
    final primary         = customPrimary ?? (isDark ? AppColors.primaryDark : AppColors.primary);
    final primaryFg       = _contrastColor(primary);
    final primaryContainer = isDark ? AppColors.primaryContainerDark : AppColors.primaryContainer;
    final onPrimaryContainer = isDark ? AppColors.indigo200          : AppColors.indigo700;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: primaryFg,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: isDark ? AppColors.secondaryDark : AppColors.secondary,
      onSecondary: isDark ? AppColors.secondaryForegroundDark : AppColors.secondaryForeground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      surface: cardColor,
      onSurface: fg,
      outline: borderCol,
      surfaceContainerHighest: mutedCol,
      onSurfaceVariant: mutedFg,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,


      // --- AppBar ---
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h4.copyWith(color: fg),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // --- Card ---
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: borderCol),
        ),
        margin: EdgeInsets.zero,
      ),

      // --- Input ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: borderCol),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: borderCol),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.destructive),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.destructive, width: 2),
        ),
        hintStyle: AppTextStyles.body.copyWith(color: mutedFg),
        labelStyle: AppTextStyles.label.copyWith(color: mutedFg),
        errorStyle: AppTextStyles.labelSM.copyWith(color: AppColors.destructive),
      ),

      // --- Elevated Button (primary) ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryFg,
          disabledBackgroundColor: mutedCol,
          disabledForegroundColor: mutedFg,
          elevation: 0,
          shadowColor: AppColors.transparent,
          textStyle: AppTextStyles.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          minimumSize: const Size(double.infinity, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),

      // --- Outlined Button (secondary) ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: borderCol),
          textStyle: AppTextStyles.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          minimumSize: const Size(double.infinity, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),

      // --- Text Button (ghost / link) ---
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: fg,
          textStyle: AppTextStyles.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // --- Divider ---
      dividerTheme: DividerThemeData(
        color: borderCol,
        thickness: 1,
        space: 0,
      ),

      // --- SnackBar ---
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.zinc50 : AppColors.zinc900,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: isDark ? AppColors.zinc900 : AppColors.zinc50,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),

      // --- ListTile ---
      listTileTheme: ListTileThemeData(
        tileColor: cardColor,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
        titleTextStyle: AppTextStyles.labelLG.copyWith(color: fg),
        subtitleTextStyle: AppTextStyles.bodySM,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // --- Typography ---
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        headlineMedium: AppTextStyles.h3,
        headlineSmall: AppTextStyles.h4,
        bodyLarge: AppTextStyles.bodyLG,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.bodySM,
        labelLarge: AppTextStyles.labelLG,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.labelSM,
      ).apply(
        bodyColor: fg,
        displayColor: fg,
      ),
    );
  }

  /// Devuelve blanco o negro según la luminancia del color base.
  static Color _contrastColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.35 ? AppColors.foreground : AppColors.white;
  }
}
