import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hometasks/core/models/family_member.dart';
import 'package:hometasks/core/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestión de miembros con persistencia en SharedPreferences.
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
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    final loaded =
        decoded
            .cast<Map<String, dynamic>>()
            .map(FamilyMember.fromJson)
            .toList();

    membersNotifier.value = _migrateIds(loaded);

    // Persiste si la migración cambió algún id.
    if (_hasDuplicateIds(loaded)) await _persist();
  }

  /// Detecta miembros con IDs duplicados (formato legacy: userId sin sufijo de grupo)
  /// y los renombra a `${id}_${groupId}` para garantizar unicidad global.
  List<FamilyMember> _migrateIds(List<FamilyMember> members) {
    final idCounts = <String, int>{};
    for (final m in members) {
      idCounts[m.id] = (idCounts[m.id] ?? 0) + 1;
    }

    return members.map((m) {
      final isDuplicate = (idCounts[m.id] ?? 0) > 1;
      final alreadyMigrated = m.id.endsWith('_${m.groupId}');
      if (!isDuplicate || alreadyMigrated) return m;
      return m.copyWith(id: '${m.id}_${m.groupId}');
    }).toList();
  }

  bool _hasDuplicateIds(List<FamilyMember> members) {
    final ids = members.map((m) => m.id).toSet();
    return ids.length != members.length;
  }

  /// Retorna los miembros que pertenecen al grupo [groupId].
  List<FamilyMember> forGroup(String groupId) =>
      members.where((m) => m.groupId == groupId).toList();

  Future<void> add(FamilyMember member) async {
    membersNotifier.value = [...members, member];
    await _persist();
  }

  /// Crea y persiste un miembro inicial (el dueño del grupo) con los datos
  /// del usuario autenticado. Si ya existe un miembro con el mismo [userId]
  /// en el grupo, no hace nada para evitar duplicados.
  ///
  /// El [id] del miembro es `${userId}_${groupId}` para garantizar unicidad
  /// global cuando un usuario es dueño de múltiples grupos.
  Future<void> addOwnerIfAbsent({
    required String userId,
    required String userName,
    required String groupId,
  }) async {
    final memberId = '${userId}_$groupId';
    final alreadyExists = members.any(
      (m) => m.id == memberId && m.groupId == groupId,
    );
    if (alreadyExists) return;

    final colorIndex =
        userId.codeUnits.fold(0, (a, b) => a + b) % kAvatarColors.length;

    await add(
      FamilyMember(
        id: memberId,
        name: userName,
        groupId: groupId,
        avatarColor: kAvatarColors[colorIndex],
      ),
    );
  }

  Future<void> update(FamilyMember updated) async {
    membersNotifier.value =
        members.map((m) => m.id == updated.id ? updated : m).toList();
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
      member.copyWith(totalXp: newTotalXp, level: newLevel, score: newScore),
    );
  }

  /// Resta [amount] XP al miembro (nunca baja de 0). Recalcula nivel y score.
  Future<void> removeXp(String memberId, int amount) async {
    final member = _findMember(memberId);
    if (member == null) return;

    final newTotalXp =
        (member.totalXp - amount).clamp(0, double.maxFinite).toInt();
    final newLevel = (newTotalXp / 100).floor() + 1;
    final newScore = (member.score - amount).clamp(0, double.maxFinite).toInt();

    await update(
      member.copyWith(totalXp: newTotalXp, level: newLevel, score: newScore),
    );
  }

  /// Incrementa el contador histórico de tareas completadas.
  Future<void> incrementTotalTasks(String memberId) async {
    final member = _findMember(memberId);
    if (member == null) return;
    await update(member.copyWith(totalTasks: member.totalTasks + 1));
  }

  /// Decrementa el contador histórico (al desmarcar una tarea completada).
  Future<void> decrementTotalTasks(String memberId) async {
    final member = _findMember(memberId);
    if (member == null) return;
    final newTotal = (member.totalTasks - 1).clamp(0, double.maxFinite).toInt();
    await update(member.copyWith(totalTasks: newTotal));
  }

  /// Recalcula la racha de días consecutivos en los que el miembro completó
  /// todas sus tareas asignadas. Requiere que [tasksProvider] esté asignado.
  ///
  /// Los días sin tareas asignadas se omiten (no rompen la racha), dado que
  /// no se puede completar algo que no existe.
  Future<void> recalcStreak(String memberId) async {
    final member = _findMember(memberId);
    if (member == null || tasksProvider == null) return;

    final allTasks = tasksProvider!();
    final memberTasks =
        allTasks.where((t) => t.assigneeId == memberId).toList();

    if (memberTasks.isEmpty) {
      await update(member.copyWith(streakDays: 0));
      return;
    }

    final today = _dateOnly(DateTime.now());
    var streak = 0;
    var checkDay = today;

    // Retrocede hasta 365 días para evitar bucle infinito.
    for (var i = 0; i < 365; i++) {
      final dayTasks =
          memberTasks.where((t) => _dateOnly(t.date) == checkDay).toList();

      if (dayTasks.isEmpty) {
        // Sin tareas ese día: lo saltamos (no rompe la racha).
        checkDay = checkDay.subtract(const Duration(days: 1));
        continue;
      }

      if (dayTasks.any((t) => !t.completed)) break;

      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    await update(member.copyWith(streakDays: streak));
  }

  /// Limpia todos los miembros de memoria y SharedPreferences.
  /// Se llama al cerrar sesión para evitar que un segundo usuario
  /// vea datos del usuario anterior.
  Future<void> clearAll() async {
    membersNotifier.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
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

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
