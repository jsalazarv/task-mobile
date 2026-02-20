import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hometasks/core/models/group.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestión de grupos con persistencia en SharedPreferences.
///
/// Expone [groupsNotifier] para que la UI pueda reaccionar reactivamente.
class GroupService {
  GroupService._();

  static final instance = GroupService._();

  static const _storageKey = 'groups_v1';

  final groupsNotifier = ValueNotifier<List<Group>>([]);

  List<Group> get groups => groupsNotifier.value;

  /// Carga los grupos desde SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    groupsNotifier.value =
        decoded.cast<Map<String, dynamic>>().map(Group.fromJson).toList();
  }

  Future<void> add(Group group) async {
    groupsNotifier.value = [...groups, group];
    await _persist();
  }

  Future<void> update(Group updated) async {
    groupsNotifier.value =
        groups.map((g) => g.id == updated.id ? updated : g).toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    groupsNotifier.value = groups.where((g) => g.id != id).toList();
    await _persist();
  }

  Group? findById(String id) {
    final index = groups.indexWhere((g) => g.id == id);
    return index == -1 ? null : groups[index];
  }

  /// Crea el grupo legacy "Mi Hogar" para migrar datos anteriores a la
  /// introducción del sistema de grupos. Retorna el grupo creado.
  Future<Group> createLegacyGroup(String homeName) async {
    final legacy = Group(
      id: 'legacy-home-group',
      name: homeName.isNotEmpty ? homeName : 'Mi Hogar',
      type: GroupType.home,
      color: AppColors.indigo500,
      createdAt: DateTime.now(),
    );
    await add(legacy);
    return legacy;
  }

  /// Limpia todos los grupos de memoria y SharedPreferences al cerrar sesión.
  Future<void> clearAll() async {
    groupsNotifier.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(groups.map((g) => g.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
