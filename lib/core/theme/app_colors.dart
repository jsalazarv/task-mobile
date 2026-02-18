import 'package:flutter/material.dart';

/// Design tokens inspirados en shadcn/ui — paleta Índigo/Violeta gamificada.
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

  // ---------- Índigo (primary) ----------
  static const indigo50  = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo200 = Color(0xFFC7D2FE);
  static const indigo400 = Color(0xFF818CF8);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = Color(0xFF4F46E5);
  static const indigo700 = Color(0xFF4338CA);
  static const indigo900 = Color(0xFF312E81);
  static const indigo950 = Color(0xFF1E1B4B);

  // ---------- Violeta (primaryContainer) ----------
  static const violet100 = Color(0xFFEDE9FE);
  static const violet400 = Color(0xFFA78BFA);
  static const violet600 = Color(0xFF7C3AED);

  // ---------- XP / Gamificación ----------
  static const xpGold      = Color(0xFFF59E0B);
  static const xpGoldLight = Color(0xFFFFFBEB);
  static const xpGoldDark  = Color(0xFF78350F);

  static const streakOrange      = Color(0xFFF97316);
  static const streakOrangeLight = Color(0xFFFFF7ED);
  static const streakOrangeDark  = Color(0xFF7C2D12);

  // ---------- Semánticos (light) ----------
  static const background      = Color(0xFFF5F5FF);  // off-white con tinte índigo
  static const foreground      = zinc950;
  static const card            = Color(0xFFFFFFFF);
  static const cardForeground  = zinc950;
  static const border          = Color(0xFFE0E7FF);   // indigo100
  static const input           = Color(0xFFE0E7FF);
  static const ring            = indigo600;
  static const muted           = Color(0xFFF0F0FF);
  static const mutedForeground = zinc500;

  // ---------- Primary (light) ----------
  static const primary           = indigo600;
  static const primaryForeground = zinc50;
  static const primaryContainer  = indigo100;

  // ---------- Secondary (light) ----------
  static const secondary           = Color(0xFFF0F0FF);
  static const secondaryForeground = indigo700;

  // ---------- Destructive ----------
  static const destructive           = Color(0xFFEF4444);
  static const destructiveForeground = Color(0xFFFAFAFA);

  // ---------- Semánticos (dark) — paleta índigo profunda tipo referencia ----------
  static const backgroundDark      = Color(0xFF0D0B1E);  // casi negro, tinte índigo saturado
  static const foregroundDark      = Color(0xFFF0EEFF);  // blanco levemente violáceo
  static const cardDark            = Color(0xFF16133A);  // índigo muy oscuro
  static const borderDark          = Color(0xFF2A2560);  // índigo oscuro para separadores
  static const mutedDark           = Color(0xFF1E1A40);
  static const mutedForegroundDark = Color(0xFF8B87C0);  // violeta lavanda
  static const primaryDark         = indigo400;
  static const primaryForegroundDark = zinc950;
  static const primaryContainerDark  = Color(0xFF1E1A50);
  static const secondaryDark          = Color(0xFF1E1A40);
  static const secondaryForegroundDark = indigo400;

  // ---------- Glass (dark) ----------
  /// Fondo semitransparente para glassmorphism en tema oscuro.
  static const glassDarkBg     = Color(0x0FFFFFFF);  // white 6%
  static const glassDarkBorder = Color(0x1FFFFFFF);  // white 12% — solo para hero/podio

  /// Borde sutil índigo para cards normales en tema oscuro.
  /// Armoniza con el fondo sin hacer contraste fuerte.
  static const cardDarkBorder  = Color(0xFF2D2A6E);  // índigo oscuro 45%

  // ---------- Categorías de tareas ----------
  static const categoryCleaningBg    = Color(0xFFEFF6FF);
  static const categoryCleaningFg    = Color(0xFF1D4ED8);
  static const categoryShoppingBg    = Color(0xFFFFF1F2);
  static const categoryShoppingFg    = Color(0xFFBE123C);
  static const categoryGardenBg      = Color(0xFFF0FDF4);
  static const categoryGardenFg      = Color(0xFF15803D);
  static const categoryCookingBg     = Color(0xFFFFF7ED);
  static const categoryCookingFg     = Color(0xFFC2410C);
  static const categoryLaundryBg     = Color(0xFFF5F3FF);
  static const categoryLaundryFg     = Color(0xFF6D28D9);
  static const categoryOrganizingBg  = Color(0xFFFFF7ED);
  static const categoryOrganizingFg  = Color(0xFF92400E);

  // ---------- Utils ----------
  static const white       = Color(0xFFFFFFFF);
  static const black       = Color(0xFF000000);
  static const transparent = Colors.transparent;
}
