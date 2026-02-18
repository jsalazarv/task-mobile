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

  // Label en mayúsculas para los badges de las task cards
  String get labelUpper => label.toUpperCase();
}

class TaskMock {
  const TaskMock({
    required this.title,
    required this.time,
    required this.category,
    this.description,
    this.completed = false,
    this.assignee,
  });

  final String title;
  final String? description;
  final String time;
  final TaskCategory category;
  final bool completed;
  final String? assignee;

  TaskMock copyWith({
    String? title,
    String? description,
    String? time,
    TaskCategory? category,
    bool? completed,
    String? assignee,
  }) =>
      TaskMock(
        title: title ?? this.title,
        description: description ?? this.description,
        time: time ?? this.time,
        category: category ?? this.category,
        completed: completed ?? this.completed,
        assignee: assignee ?? this.assignee,
      );
}

/// Tareas de la semana completa (vista semanal).
final kWeekTasks = <TaskMock>[
  const TaskMock(
    title: 'Limpiar ventanas',
    description: 'Limpiar todas las ventanas de la casa por dentro y por fuer...',
    time: '8:30',
    category: TaskCategory.limpieza,
    completed: true,
  ),
  const TaskMock(
    title: 'Comprar frutas y verduras',
    description: 'Manzanas, plátanos, tomates, cebollas, lechuga y...',
    time: '10:00',
    category: TaskCategory.compras,
    completed: true,
  ),
  const TaskMock(
    title: 'Regar plantas del balcón',
    time: '18:00',
    category: TaskCategory.jardin,
  ),
  const TaskMock(
    title: 'Preparar cena',
    time: '19:00',
    category: TaskCategory.cocina,
    assignee: 'Carlos',
  ),
  const TaskMock(
    title: 'Limpiar baños',
    time: '9:00',
    category: TaskCategory.limpieza,
  ),
  const TaskMock(
    title: 'Hacer la compra semanal',
    description: 'Lista completa en la app de notas',
    time: '11:00',
    category: TaskCategory.compras,
  ),
];

/// Tareas del día actual (vista diaria).
final kDayTasks = <TaskMock>[
  const TaskMock(
    title: 'Limpiar ventanas',
    description: 'Limpiar todas las ventanas de la casa por dentro y por fuer...',
    time: '8:30',
    category: TaskCategory.limpieza,
    completed: true,
  ),
  const TaskMock(
    title: 'Regar plantas del balcón',
    time: '18:00',
    category: TaskCategory.jardin,
  ),
  const TaskMock(
    title: 'Preparar cena',
    time: '19:00',
    category: TaskCategory.cocina,
    assignee: 'Carlos',
  ),
];

// Alias para mantener compatibilidad con código existente.
final kMockTasks = kWeekTasks;
