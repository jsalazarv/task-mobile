import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestión de miembros de la familia con persistencia en SharedPreferences.
///
/// Expone un [ValueNotifier] para que la UI pueda reaccionar reactivamente
/// sin necesidad de un BLoC dedicado en esta fase.
class MemberService {
  MemberService._();

  static final instance = MemberService._();

  static const _storageKey = 'family_members_v1';

  final membersNotifier = ValueNotifier<List<FamilyMember>>([]);

  List<FamilyMember> get members => membersNotifier.value;

  /// Función inyectable para obtener las tareas (evita dependencia circular
  /// con TaskService; se asigna en main.dart tras inicializar ambos servicios).
  List<Task> Function()? tasksProvider;

  /// Carga los miembros desde SharedPreferences.
  /// Si no hay datos persistidos, usa el fallback de mocks.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      membersNotifier.value = List.of(kFamilyMembersFallback);
      return;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    membersNotifier.value = decoded
        .cast<Map<String, dynamic>>()
        .map(FamilyMember.fromJson)
        .toList();
  }

  Future<void> add(FamilyMember member) async {
    membersNotifier.value = [...members, member];
    await _persist();
  }

  Future<void> update(FamilyMember updated) async {
    membersNotifier.value = members
        .map((m) => m.id == updated.id ? updated : m)
        .toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    membersNotifier.value = members.where((m) => m.id != id).toList();
    await _persist();
  }

  /// Suma [amount] XP al miembro. Recalcula nivel y score semanal.
  Future<void> addXp(String memberId, int amount) async {
    final member = _findMember(memberId);
    if (member == null) return;

    final newTotalXp = member.totalXp + amount;
    final newLevel = (newTotalXp / 100).floor() + 1;
    final newScore = member.score + amount;

    await update(
      member.copyWith(
        totalXp: newTotalXp,
        level: newLevel,
        score: newScore,
      ),
    );
  }

  /// Resta [amount] XP al miembro (nunca baja de 0). Recalcula nivel y score.
  Future<void> removeXp(String memberId, int amount) async {
    final member = _findMember(memberId);
    if (member == null) return;

    final newTotalXp = (member.totalXp - amount).clamp(0, double.maxFinite).toInt();
    final newLevel = (newTotalXp / 100).floor() + 1;
    final newScore = (member.score - amount).clamp(0, double.maxFinite).toInt();

    await update(
      member.copyWith(
        totalXp: newTotalXp,
        level: newLevel,
        score: newScore,
      ),
    );
  }

  /// Recalcula la racha de días consecutivos en los que el miembro completó
  /// todas sus tareas asignadas. Requiere que [tasksProvider] esté asignado.
  Future<void> recalcStreak(String memberId) async {
    final member = _findMember(memberId);
    if (member == null || tasksProvider == null) return;

    final allTasks = tasksProvider!();
    final memberTasks = allTasks.where((t) => t.assigneeId == memberId).toList();

    if (memberTasks.isEmpty) {
      await update(member.copyWith(streakDays: 0));
      return;
    }

    final today = _dateOnly(DateTime.now());
    var streak = 0;
    var checkDay = today;

    while (true) {
      final dayTasks =
          memberTasks.where((t) => _dateOnly(t.date) == checkDay).toList();

      if (dayTasks.isEmpty || dayTasks.any((t) => !t.completed)) break;

      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    await update(member.copyWith(streakDays: streak));
  }

  FamilyMember? _findMember(String id) {
    final index = members.indexWhere((m) => m.id == id);
    return index == -1 ? null : members[index];
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(members.map((m) => m.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
