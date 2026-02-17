import 'package:flutter/material.dart';

/// Design tokens inspirados en shadcn/ui (paleta Zinc).
/// Referencia: https://ui.shadcn.com/themes
abstract final class AppColors {
  // ---------- Zinc (surface / neutral) ----------
  static const zinc50  = Color(0xFFFAFAFA);
  static const zinc100 = Color(0xFFF4F4F5);
  static const zinc200 = Color(0xFFE4E4E7);
  static const zinc300 = Color(0xFFD4D4D8);
  static const zinc400 = Color(0xFFA1A1AA);
  static const zinc500 = Color(0xFF71717A);
  static const zinc600 = Color(0xFF52525B);
  static const zinc700 = Color(0xFF3F3F46);
  static const zinc800 = Color(0xFF27272A);
  static const zinc900 = Color(0xFF18181B);
  static const zinc950 = Color(0xFF09090B);

  // ---------- Semánticos (light) ----------
  static const background     = zinc50;
  static const foreground     = zinc950;
  static const card           = Color(0xFFFFFFFF);
  static const cardForeground = zinc950;
  static const border         = zinc200;
  static const input          = zinc200;
  static const ring           = zinc950;
  static const muted          = zinc100;
  static const mutedForeground= zinc500;

  // ---------- Primary ----------
  static const primary            = zinc900;
  static const primaryForeground  = zinc50;

  // ---------- Secondary ----------
  static const secondary           = zinc100;
  static const secondaryForeground = zinc900;

  // ---------- Destructive ----------
  static const destructive           = Color(0xFFEF4444);
  static const destructiveForeground = Color(0xFFFAFAFA);

  // ---------- Semánticos dark ----------
  static const backgroundDark      = zinc950;
  static const foregroundDark      = zinc50;
  static const cardDark            = zinc900;
  static const borderDark          = zinc800;
  static const mutedDark           = zinc800;
  static const mutedForegroundDark = zinc400;
  static const primaryDark         = zinc50;
  static const primaryForegroundDark = zinc900;
  static const secondaryDark       = zinc800;
  static const secondaryForegroundDark = zinc50;

  // ---------- Utils ----------
  static const white       = Color(0xFFFFFFFF);
  static const black       = Color(0xFF000000);
  static const transparent = Colors.transparent;
}
