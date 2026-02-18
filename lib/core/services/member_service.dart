import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';
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

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(members.map((m) => m.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
