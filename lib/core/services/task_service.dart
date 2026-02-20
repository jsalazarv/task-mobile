import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hometasks/core/models/task.dart';
import 'package:hometasks/core/models/task_category_model.dart';
import 'package:hometasks/core/services/group_service.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestión de tareas con persistencia en SharedPreferences.
///
/// Expone [tasksNotifier] para que la UI reaccione reactivamente.
/// Las vistas (día/semana/grupo) filtran localmente sobre la lista completa.
class TaskService {
  TaskService._();

  static final instance = TaskService._();

  static const _storageKey = 'tasks_v1';

  final tasksNotifier = ValueNotifier<List<Task>>([]);

  List<Task> get tasks => tasksNotifier.value;

  /// Carga las tareas persistidas. Si no hay datos la lista queda vacía.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    tasksNotifier.value =
        decoded.cast<Map<String, dynamic>>().map(Task.fromJson).toList();
  }

  /// Tareas filtradas para un día concreto.
  List<Task> forDay(DateTime day) {
    final d = _dateOnly(day);
    return tasks.where((t) => _dateOnly(t.date) == d).toList();
  }

  /// Tareas filtradas para la semana que contiene [weekStart] (lunes).
  List<Task> forWeek(DateTime weekStart) {
    final monday = _dateOnly(weekStart);
    final sunday = monday.add(const Duration(days: 6));
    return tasks.where((t) {
        final d = _dateOnly(t.date);
        return !d.isBefore(monday) && !d.isAfter(sunday);
      }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Tareas filtradas para un día concreto dentro de un grupo.
  List<Task> forGroupAndDay(String groupId, DateTime day) {
    final d = _dateOnly(day);
    return tasks
        .where((t) => t.groupId == groupId && _dateOnly(t.date) == d)
        .toList();
  }

  /// Tareas filtradas para la semana dentro de un grupo.
  List<Task> forGroupAndWeek(String groupId, DateTime weekStart) {
    final monday = _dateOnly(weekStart);
    final sunday = monday.add(const Duration(days: 6));
    return tasks.where((t) {
        if (t.groupId != groupId) return false;
        final d = _dateOnly(t.date);
        return !d.isBefore(monday) && !d.isAfter(sunday);
      }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> add(Task task) async {
    tasksNotifier.value = [...tasks, task];
    await _persist();
  }

  Future<void> update(Task updated) async {
    tasksNotifier.value =
        tasks.map((t) => t.id == updated.id ? updated : t).toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    tasksNotifier.value = tasks.where((t) => t.id != id).toList();
    await _persist();
  }

  /// Alterna el estado de completado de una tarea.
  /// Si tiene asignado un miembro, suma o resta su XP, actualiza totalTasks
  /// y recalcula la racha.
  Future<void> toggleCompleted(String id) async {
    final task = tasks.where((t) => t.id == id).firstOrNull;
    if (task == null) return;

    final nowCompleted = !task.completed;
    await update(task.copyWith(completed: nowCompleted));

    final assigneeId = task.assigneeId;
    if (assigneeId == null || assigneeId.isEmpty) return;

    if (nowCompleted) {
      await MemberService.instance.addXp(assigneeId, task.xpValue);
      await MemberService.instance.incrementTotalTasks(assigneeId);
    } else {
      await MemberService.instance.removeXp(assigneeId, task.xpValue);
      await MemberService.instance.decrementTotalTasks(assigneeId);
    }

    await MemberService.instance.recalcStreak(assigneeId);
  }

  /// Persiste el nuevo orden de las tareas de un día para un miembro.
  ///
  /// [orderedIds] es la lista de IDs en el orden deseado. Asigna [sortOrder]
  /// incremental a cada tarea encontrada y persiste el resultado.
  Future<void> reorderDay(List<String> orderedIds) async {
    final updated = List<Task>.from(tasks);
    for (var i = 0; i < orderedIds.length; i++) {
      final idx = updated.indexWhere((t) => t.id == orderedIds[i]);
      if (idx != -1) {
        updated[idx] = updated[idx].copyWith(sortOrder: i);
      }
    }
    tasksNotifier.value = updated;
    await _persist();
  }

  /// Resuelve el [TaskCategoryModel] de una tarea buscando en las categorías
  /// del grupo al que pertenece. Si no se encuentra, retorna el default
  /// correspondiente al id o el fallback [DefaultCategories.limpieza].
  TaskCategoryModel resolveCategory(Task task) {
    final group = GroupService.instance.findById(task.groupId);
    if (group != null) {
      final match =
          group.categories.where((c) => c.id == task.categoryId).firstOrNull;
      if (match != null) return match;
    }
    return DefaultCategories.byId[task.categoryId] ??
        DefaultCategories.limpieza;
  }

  /// Limpia todas las tareas de memoria y SharedPreferences al cerrar sesión.
  Future<void> clearAll() async {
    tasksNotifier.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
