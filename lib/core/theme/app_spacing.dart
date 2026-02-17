import 'package:flutter/material.dart';

/// Escala de espaciado alineada con Tailwind CSS / shadcn/ui.
abstract final class AppSpacing {
  static const double px  = 1;
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double x2l = 24;
  static const double x3l = 32;
  static const double x4l = 40;
  static const double x5l = 48;
  static const double x6l = 64;

  static const pagePadding  = EdgeInsets.symmetric(horizontal: lg, vertical: x2l);
  static const cardPadding  = EdgeInsets.all(x2l);
  static const inputPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
}
