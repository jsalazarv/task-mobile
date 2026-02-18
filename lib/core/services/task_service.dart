import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestión de tareas con persistencia en SharedPreferences.
///
/// Expone [tasksNotifier] para que la UI reaccione reactivamente.
/// Las vistas (día/semana) filtran localmente sobre la lista completa.
class TaskService {
  TaskService._();

  static final instance = TaskService._();

  static const _storageKey = 'tasks_v1';

  final tasksNotifier = ValueNotifier<List<Task>>([]);

  List<Task> get tasks => tasksNotifier.value;

  /// Carga las tareas persistidas. Si no hay datos usa el fallback.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      tasksNotifier.value = List.of(kTasksFallback);
      return;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    tasksNotifier.value = decoded
        .cast<Map<String, dynamic>>()
        .map(Task.fromJson)
        .toList();
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
    return tasks
        .where((t) {
          final d = _dateOnly(t.date);
          return !d.isBefore(monday) && !d.isAfter(sunday);
        })
        .toList()
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

  Future<void> toggleCompleted(String id) async {
    final task = tasks.firstWhere((t) => t.id == id);
    await update(task.copyWith(completed: !task.completed));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
