import 'package:flutter/material.dart';
import 'package:hometasks/core/theme/app_colors.dart';

enum TaskCategory { limpieza, cocina, lavanderia, jardin, compras, organizacion }

extension TaskCategoryX on TaskCategory {
  String get label => switch (this) {
        TaskCategory.limpieza     => 'Limpieza',
        TaskCategory.compras      => 'Compras',
        TaskCategory.jardin       => 'Jardín',
        TaskCategory.cocina       => 'Cocina',
        TaskCategory.lavanderia   => 'Lavandería',
        TaskCategory.organizacion => 'Organización',
      };

  String get emoji => switch (this) {
        TaskCategory.limpieza     => '✨',
        TaskCategory.compras      => '🛒',
        TaskCategory.jardin       => '🌿',
        TaskCategory.cocina       => '🍳',
        TaskCategory.lavanderia   => '👕',
        TaskCategory.organizacion => '📦',
      };

  Color get foreground => switch (this) {
        TaskCategory.limpieza     => AppColors.categoryCleaningFg,
        TaskCategory.compras      => AppColors.categoryShoppingFg,
        TaskCategory.jardin       => AppColors.categoryGardenFg,
        TaskCategory.cocina       => AppColors.categoryCookingFg,
        TaskCategory.lavanderia   => AppColors.categoryLaundryFg,
        TaskCategory.organizacion => AppColors.categoryOrganizingFg,
      };

  Color get background => switch (this) {
        TaskCategory.limpieza     => AppColors.categoryCleaningBg,
        TaskCategory.compras      => AppColors.categoryShoppingBg,
        TaskCategory.jardin       => AppColors.categoryGardenBg,
        TaskCategory.cocina       => AppColors.categoryCookingBg,
        TaskCategory.lavanderia   => AppColors.categoryLaundryBg,
        TaskCategory.organizacion => AppColors.categoryOrganizingBg,
      };

  String get labelUpper => label.toUpperCase();

  String get key => name;

  static TaskCategory fromKey(String key) =>
      TaskCategory.values.firstWhere((c) => c.name == key);
}

// ── Modelo principal ──────────────────────────────────────────────────────────

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.description,
    this.time,
    this.assigneeId,
    this.completed = false,
    this.xpValue = 10,
  });

  final String id;
  final String title;
  final String? description;
  final String? time;
  final TaskCategory category;

  /// Fecha a la que pertenece la tarea (sin hora).
  final DateTime date;

  /// ID del [FamilyMember] asignado, o null si sin asignar.
  final String? assigneeId;
  final bool completed;

  /// Puntos XP que vale esta tarea al completarse.
  final int xpValue;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    TaskCategory? category,
    DateTime? date,
    String? assigneeId,
    bool? completed,
    int? xpValue,
    bool clearAssignee = false,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        time: time ?? this.time,
        category: category ?? this.category,
        date: date ?? this.date,
        assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
        completed: completed ?? this.completed,
        xpValue: xpValue ?? this.xpValue,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'time': time,
        'category': category.key,
        'date': date.toIso8601String(),
        'assigneeId': assigneeId,
        'completed': completed,
        'xpValue': xpValue,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        time: json['time'] as String?,
        category: TaskCategoryX.fromKey(json['category'] as String),
        date: DateTime.parse(json['date'] as String),
        assigneeId: json['assigneeId'] as String?,
        completed: json['completed'] as bool? ?? false,
        xpValue: json['xpValue'] as int? ?? 10,
      );
}

// ── Alias de compatibilidad (usado en código legacy mientras se migra) ─────────

/// @deprecated Usar [Task] directamente.
typedef TaskMock = Task;

// ── Fallback de tareas iniciales ──────────────────────────────────────────────

final _today = DateTime.now();
final _d = DateTime(_today.year, _today.month, _today.day);

final kTasksFallback = <Task>[
  Task(
    id: 'fallback-1',
    title: 'Limpiar ventanas',
    description: 'Limpiar todas las ventanas de la casa por dentro y por fuera',
    time: '8:30 AM',
    category: TaskCategory.limpieza,
    date: _d,
    completed: true,
  ),
  Task(
    id: 'fallback-2',
    title: 'Regar plantas del balcón',
    time: '6:00 PM',
    category: TaskCategory.jardin,
    date: _d,
  ),
  Task(
    id: 'fallback-3',
    title: 'Preparar cena',
    time: '7:00 PM',
    category: TaskCategory.cocina,
    date: _d,
  ),
  Task(
    id: 'fallback-4',
    title: 'Hacer la compra semanal',
    description: 'Lista completa en la app de notas',
    time: '11:00 AM',
    category: TaskCategory.compras,
    date: _d,
  ),
];
