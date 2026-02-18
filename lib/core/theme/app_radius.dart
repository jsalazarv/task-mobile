import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double none = 0;
  static const double sm   = 4;
  static const double md   = 6;
  static const double lg   = 8;
  static const double xl   = 12;
  static const double full = 9999;

  static const double x2l = 20;
  static const double x3l = 28;

  static const card   = BorderRadius.all(Radius.circular(x2l));
  static const cardXl = BorderRadius.all(Radius.circular(x2l));
  static const cardX2l= BorderRadius.all(Radius.circular(x3l));
  static const button = BorderRadius.all(Radius.circular(md));
  static const input  = BorderRadius.all(Radius.circular(md));
  static const badge  = BorderRadius.all(Radius.circular(full));
}
