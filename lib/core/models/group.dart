import 'package:flutter/material.dart';
import 'package:hometasks/core/models/task_category_model.dart';

// ── Rol dentro del grupo ──────────────────────────────────────────────────────

enum GroupRole { admin, member }

extension GroupRoleX on GroupRole {
  String get label => switch (this) {
    GroupRole.admin => 'Administrador',
    GroupRole.member => 'Miembro',
  };

  String get key => name;

  static GroupRole fromKey(String key) =>
      GroupRole.values.firstWhere((r) => r.name == key);
}

// ── Tipo de grupo ─────────────────────────────────────────────────────────────

enum GroupType { home, work, friends, school, other }

extension GroupTypeX on GroupType {
  String get label => switch (this) {
    GroupType.home => 'Hogar',
    GroupType.work => 'Trabajo',
    GroupType.friends => 'Amigos',
    GroupType.school => 'Escuela',
    GroupType.other => 'Otro',
  };

  IconData get icon => switch (this) {
    GroupType.home => Icons.home_outlined,
    GroupType.work => Icons.business_outlined,
    GroupType.friends => Icons.people_outline,
    GroupType.school => Icons.school_outlined,
    GroupType.other => Icons.star_outline,
  };

  String get key => name;

  static GroupType fromKey(String key) => GroupType.values.firstWhere(
    (t) => t.name == key,
    orElse: () => GroupType.other,
  );
}

// ── Modelo principal ──────────────────────────────────────────────────────────

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.createdAt,
    this.description,
    List<TaskCategoryModel>? categories,
  }) : categories = categories ?? DefaultCategories.all;

  final String id;
  final String name;
  final String? description;
  final GroupType type;
  final Color color;
  final DateTime createdAt;

  /// Categorías de tareas habilitadas para este grupo (1–6).
  /// Por defecto incluye los 6 defaults predefinidos.
  final List<TaskCategoryModel> categories;

  IconData get typeIcon => type.icon;

  Group copyWith({
    String? id,
    String? name,
    String? description,
    GroupType? type,
    Color? color,
    DateTime? createdAt,
    List<TaskCategoryModel>? categories,
  }) => Group(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    type: type ?? this.type,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
    categories: categories ?? this.categories,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.key,
    'color': color.toARGB32(),
    'createdAt': createdAt.toIso8601String(),
    'categories': categories.map((c) => c.toJson()).toList(),
  };

  factory Group.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'] as List<dynamic>?;
    final categories = _parseCategories(rawCategories);

    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: GroupTypeX.fromKey(json['type'] as String? ?? 'other'),
      color: Color(json['color'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      categories: categories,
    );
  }

  /// Parsea categorías soportando tanto el formato nuevo (Map con toJson)
  /// como el formato legacy (lista de strings con claves del enum anterior).
  static List<TaskCategoryModel> _parseCategories(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) return DefaultCategories.all;

    final first = raw.first;

    if (first is Map<String, dynamic>) {
      return raw
          .cast<Map<String, dynamic>>()
          .map(TaskCategoryModel.fromJson)
          .toList();
    }

    // Migración desde lista de strings (enum keys legacy: "limpieza", "cocina"…)
    return raw
        .cast<String>()
        .map((key) => DefaultCategories.byId[key] ?? DefaultCategories.limpieza)
        .toList();
  }
}
