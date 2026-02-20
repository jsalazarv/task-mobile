import 'package:hometasks/core/models/task_category_model.dart';

// ── Modelo principal ──────────────────────────────────────────────────────────

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.date,
    required this.groupId,
    this.description,
    this.time,
    this.assigneeId,
    this.completed = false,
    this.xpValue = 10,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String? description;
  final String? time;

  /// ID que referencia a un [TaskCategoryModel] dentro del grupo.
  final String categoryId;

  /// ID del [Group] al que pertenece esta tarea.
  final String groupId;

  /// Fecha a la que pertenece la tarea (sin hora).
  final DateTime date;

  /// ID del [FamilyMember] asignado, o null si sin asignar.
  final String? assigneeId;
  final bool completed;

  /// Puntos XP que vale esta tarea al completarse.
  final int xpValue;

  /// Orden de visualización en "Mi día". 0 = sin orden asignado.
  final int sortOrder;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    String? categoryId,
    DateTime? date,
    String? groupId,
    String? assigneeId,
    bool? completed,
    int? xpValue,
    int? sortOrder,
    bool clearAssignee = false,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    time: time ?? this.time,
    categoryId: categoryId ?? this.categoryId,
    date: date ?? this.date,
    groupId: groupId ?? this.groupId,
    assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
    completed: completed ?? this.completed,
    xpValue: xpValue ?? this.xpValue,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'time': time,
    'categoryId': categoryId,
    'date': date.toIso8601String(),
    'groupId': groupId,
    'assigneeId': assigneeId,
    'completed': completed,
    'xpValue': xpValue,
    'sortOrder': sortOrder,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    time: json['time'] as String?,
    // Migración: soporta tanto 'categoryId' (nuevo) como 'category' (legacy enum key)
    categoryId:
        json['categoryId'] as String? ??
        json['category'] as String? ??
        DefaultCategories.limpieza.id,
    date: DateTime.parse(json['date'] as String),
    groupId: json['groupId'] as String? ?? '',
    assigneeId: json['assigneeId'] as String?,
    completed: json['completed'] as bool? ?? false,
    xpValue: json['xpValue'] as int? ?? 10,
    sortOrder: json['sortOrder'] as int? ?? 0,
  );
}
