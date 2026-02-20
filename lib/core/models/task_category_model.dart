import 'package:flutter/material.dart';
import 'package:hometasks/core/constants/category_icons.dart';
import 'package:hometasks/core/theme/app_colors.dart';

/// Modelo persistido de una categoría de tareas dentro de un grupo.
///
/// Reemplaza el enum [TaskCategory] con una estructura dinámica que permite
/// crear, editar y eliminar categorías por grupo (máx 6, mín 1).
class TaskCategoryModel {
  const TaskCategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.color,
  });

  final String id;
  final String name;

  /// [IconData.codePoint] del icono elegido del catálogo [CategoryIcons.all].
  final int iconCodePoint;

  /// Color de primer plano (texto e icono). El fondo se deriva con opacidad.
  final Color color;

  /// Getter que crea IconData dinámicamente desde codePoints persistidos.
  ///
  /// NOTA TÉCNICA: Esta implementación impide tree-shaking de iconos porque
  /// el codePoint se resuelve en runtime. Para builds de release, usar:
  /// `flutter build [platform] --release --no-tree-shake-icons`
  ///
  /// Impacto: ~150-200KB adicionales por incluir todas las fuentes Material Icons.
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Color get background => color.withValues(alpha: 0.12);
  Color get foreground => color;
  String get labelUpper => name.toUpperCase();

  TaskCategoryModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    Color? color,
  }) => TaskCategoryModel(
    id: id ?? this.id,
    name: name ?? this.name,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    color: color ?? this.color,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconCodePoint': iconCodePoint,
    'color': color.toARGB32(),
  };

  factory TaskCategoryModel.fromJson(Map<String, dynamic> json) =>
      TaskCategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        color: Color(json['color'] as int),
      );

  @override
  bool operator ==(Object other) =>
      other is TaskCategoryModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ── Defaults para migración ────────────────────────────────────────────────────

/// Las 6 categorías predefinidas que se seedean en grupos existentes.
/// Preserva los colores originales del sistema de tokens de [AppColors].
abstract final class DefaultCategories {
  static const limpieza = TaskCategoryModel(
    id: 'limpieza',
    name: 'Limpieza',
    iconCodePoint: 0xe3b8, // cleaning_services_outlined
    color: AppColors.categoryCleaningFg,
  );

  static const cocina = TaskCategoryModel(
    id: 'cocina',
    name: 'Cocina',
    iconCodePoint: 0xe56c, // restaurant_outlined
    color: AppColors.categoryCookingFg,
  );

  static const lavanderia = TaskCategoryModel(
    id: 'lavanderia',
    name: 'Lavandería',
    iconCodePoint: 0xe213, // dry_cleaning_outlined
    color: AppColors.categoryLaundryFg,
  );

  static const jardin = TaskCategoryModel(
    id: 'jardin',
    name: 'Jardín',
    iconCodePoint: 0xf07d5, // yard_outlined
    color: AppColors.categoryGardenFg,
  );

  static const compras = TaskCategoryModel(
    id: 'compras',
    name: 'Compras',
    iconCodePoint: 0xe59c, // shopping_cart_outlined
    color: AppColors.categoryShoppingFg,
  );

  static const organizacion = TaskCategoryModel(
    id: 'organizacion',
    name: 'Organización',
    iconCodePoint: 0xe35b, // inventory_2_outlined
    color: AppColors.categoryOrganizingFg,
  );

  /// Lista completa de defaults, en el mismo orden que el enum original.
  static const all = [
    limpieza,
    cocina,
    lavanderia,
    jardin,
    compras,
    organizacion,
  ];

  /// Mapa de id → modelo para resolución rápida durante la migración.
  static final byId = {for (final c in all) c.id: c};
}
