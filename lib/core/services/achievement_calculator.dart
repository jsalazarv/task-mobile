import 'package:flutter/material.dart';
import 'package:hometasks/core/models/task_category_model.dart';
import 'package:hometasks/core/services/task_service.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';

// ── Definición de un logro ────────────────────────────────────────────────────

class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

// ── Resultado calculado de un logro para un grupo/semana concretos ────────────

class AchievementResult {
  const AchievementResult({required this.def, required this.earners});

  final AchievementDef def;

  /// Miembros que cumplieron la condición esta semana.
  final List<FamilyMember> earners;

  bool get unlocked => earners.isNotEmpty;
}

// ── Catálogo de logros disponibles ────────────────────────────────────────────

class AchievementCatalog {
  AchievementCatalog._();

  static const constante = AchievementDef(
    id: 'constante',
    title: 'Constante',
    subtitle: '7 días seguidos',
    icon: Icons.local_fire_department_rounded,
  );

  static const veloz = AchievementDef(
    id: 'veloz',
    title: 'Veloz',
    subtitle: '5 tareas en un día',
    icon: Icons.bolt_rounded,
  );

  static const perfecto = AchievementDef(
    id: 'perfecto',
    title: 'Perfecto',
    subtitle: 'Semana 100%',
    icon: Icons.star_rounded,
  );

  static const dedicado = AchievementDef(
    id: 'dedicado',
    title: 'Dedicado',
    subtitle: '50+ XP esta semana',
    icon: Icons.emoji_events_rounded,
  );

  static const activo = AchievementDef(
    id: 'activo',
    title: 'Activo',
    subtitle: 'Tareas en 3+ días',
    icon: Icons.wb_sunny_rounded,
  );

  static const variado = AchievementDef(
    id: 'variado',
    title: 'Variado',
    subtitle: '3+ categorías distintas',
    icon: Icons.grid_view_rounded,
  );
}

// ── Calculador ────────────────────────────────────────────────────────────────

class AchievementCalculator {
  AchievementCalculator._();

  /// Calcula los logros para todos los [members] del grupo activo en la semana
  /// definida por [weekStart] (debe ser lunes a 00:00:00).
  ///
  /// [weekTasks] son las tareas del grupo en esa semana (ya filtradas externamente).
  /// [groupCategories] se usan para decidir si incluir el logro "Variado".
  static List<AchievementResult> calculate({
    required List<FamilyMember> members,
    required List<Task> weekTasks,
    required List<TaskCategoryModel> groupCategories,
  }) {
    if (members.isEmpty) return [];

    final results = <AchievementResult>[
      _constante(members),
      _veloz(members, weekTasks),
      _perfecto(members, weekTasks),
      _dedicado(members),
      _activo(members, weekTasks),
    ];

    // "Variado" solo aparece si el grupo tiene al menos 3 categorías activas.
    if (groupCategories.length >= 3) {
      results.add(_variado(members, weekTasks));
    }

    return results;
  }

  // ── Implementaciones privadas ───────────────────────────────────────────────

  /// Constante: streakDays >= 7.
  static AchievementResult _constante(List<FamilyMember> members) {
    final earners = members.where((m) => m.streakDays >= 7).toList();
    return AchievementResult(
      def: AchievementCatalog.constante,
      earners: earners,
    );
  }

  /// Veloz: al menos 5 tareas completadas asignadas al miembro en un mismo día.
  static AchievementResult _veloz(
    List<FamilyMember> members,
    List<Task> weekTasks,
  ) {
    final completed = weekTasks.where(
      (t) => t.completed && t.assigneeId != null,
    );

    final earners =
        members.where((member) {
          // Agrupa tareas del miembro por día y busca si algún día tiene ≥5.
          final byDay = <DateTime, int>{};
          for (final t in completed) {
            if (t.assigneeId != member.id) continue;
            final day = _dateOnly(t.date);
            byDay[day] = (byDay[day] ?? 0) + 1;
          }
          return byDay.values.any((count) => count >= 5);
        }).toList();

    return AchievementResult(def: AchievementCatalog.veloz, earners: earners);
  }

  /// Perfecto: tiene al menos 1 tarea asignada esta semana y todas completadas.
  static AchievementResult _perfecto(
    List<FamilyMember> members,
    List<Task> weekTasks,
  ) {
    final earners =
        members.where((member) {
          final assigned =
              weekTasks.where((t) => t.assigneeId == member.id).toList();
          return assigned.isNotEmpty && assigned.every((t) => t.completed);
        }).toList();

    return AchievementResult(
      def: AchievementCatalog.perfecto,
      earners: earners,
    );
  }

  /// Dedicado: score semanal >= 50 XP.
  static AchievementResult _dedicado(List<FamilyMember> members) {
    final earners = members.where((m) => m.score >= 50).toList();
    return AchievementResult(
      def: AchievementCatalog.dedicado,
      earners: earners,
    );
  }

  /// Activo: tareas completadas en al menos 3 días distintos esta semana.
  static AchievementResult _activo(
    List<FamilyMember> members,
    List<Task> weekTasks,
  ) {
    final completed = weekTasks.where(
      (t) => t.completed && t.assigneeId != null,
    );

    final earners =
        members.where((member) {
          final activeDays =
              completed
                  .where((t) => t.assigneeId == member.id)
                  .map((t) => _dateOnly(t.date))
                  .toSet();
          return activeDays.length >= 3;
        }).toList();

    return AchievementResult(def: AchievementCatalog.activo, earners: earners);
  }

  /// Variado: tareas completadas en 3+ categorías distintas esta semana.
  static AchievementResult _variado(
    List<FamilyMember> members,
    List<Task> weekTasks,
  ) {
    final completed = weekTasks.where(
      (t) => t.completed && t.assigneeId != null,
    );

    final earners =
        members.where((member) {
          final categories =
              completed
                  .where((t) => t.assigneeId == member.id)
                  .map((t) => t.categoryId)
                  .toSet();
          return categories.length >= 3;
        }).toList();

    return AchievementResult(def: AchievementCatalog.variado, earners: earners);
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
