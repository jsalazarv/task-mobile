import 'package:flutter/material.dart';

import 'package:hometasks/core/theme/app_colors.dart';

/// Escala tipográfica alineada con shadcn/ui.
/// Fuente del sistema (SF Pro en iOS, Roboto en Android).
abstract final class AppTextStyles {
  static const _base = TextStyle(
    color: AppColors.foreground,
    letterSpacing: 0,
    decoration: TextDecoration.none,
  );

  // --- Display ---
  static final h1 = _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.11,
    letterSpacing: -0.5,
  );

  static final h2 = _base.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
  );

  static final h3 = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static final h4 = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // --- Body ---
  static final bodyLG = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.75,
  );

  static final body = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static final bodySM = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.mutedForeground,
  );

  // --- Label / UI ---
  static final labelLG = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  static final label = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static final labelSM = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.mutedForeground,
  );

  // --- Button ---
  static final button = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0,
  );

  // --- Monospace (código / badges) ---
  static final mono = _base.copyWith(
    fontSize: 13,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
