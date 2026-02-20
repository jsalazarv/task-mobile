import 'package:flutter/material.dart';
import 'package:hometasks/core/theme/app_colors.dart';

// Sentinel para distinguir "no pasar valor" de "pasar null explícito" en copyWith.
const _absent = Object();

// ── Gradientes de podio ───────────────────────────────────────────────────────

const podiumGoldGradient = LinearGradient(
  colors: [Color(0xFFFCD34D), Color(0xFFF59E0B), Color(0xFFD97706)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const podiumSilverGradient = LinearGradient(
  colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1), Color(0xFF94A3B8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const podiumBronzeGradient = LinearGradient(
  colors: [Color(0xFFD97706), Color(0xFFB45309), Color(0xFF92400E)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const podiumIndigoGradient = LinearGradient(
  colors: [AppColors.indigo400, AppColors.indigo600],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

LinearGradient podiumGradientForRank(int rank) => switch (rank) {
  1 => podiumGoldGradient,
  2 => podiumSilverGradient,
  3 => podiumBronzeGradient,
  _ => podiumIndigoGradient,
};

// ── Modelo ────────────────────────────────────────────────────────────────────

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.groupId,
    this.nickname,
    this.avatarImagePath,
    required this.avatarColor,
    this.score = 0,
    this.totalXp = 0,
    this.totalTasks = 0,
    this.level = 1,
    this.streakDays = 0,
  });

  final String id;
  final String name;

  /// ID del [Group] al que pertenece este miembro.
  final String groupId;

  final String? nickname;
  final String? avatarImagePath;
  final Color avatarColor;

  /// XP acumulado en la semana actual (para el podio semanal).
  final int score;

  /// XP total histórico acumulado (determina el nivel).
  final int totalXp;

  final int totalTasks;
  final int level;
  final int streakDays;

  String get initial => name[0].toUpperCase();
  String get displayName => nickname ?? name;

  /// Progreso normalizado entre 0.0 y 1.0.
  double get progress => totalTasks == 0 ? 0 : score / totalTasks;

  FamilyMember copyWith({
    String? id,
    String? name,
    String? groupId,
    // Usa Object? con sentinel para permitir limpiar campos nullable.
    Object? nickname = _absent,
    Object? avatarImagePath = _absent,
    Color? avatarColor,
    int? score,
    int? totalXp,
    int? totalTasks,
    int? level,
    int? streakDays,
  }) => FamilyMember(
    id: id ?? this.id,
    name: name ?? this.name,
    groupId: groupId ?? this.groupId,
    nickname:
        identical(nickname, _absent) ? this.nickname : nickname as String?,
    avatarImagePath:
        identical(avatarImagePath, _absent)
            ? this.avatarImagePath
            : avatarImagePath as String?,
    avatarColor: avatarColor ?? this.avatarColor,
    score: score ?? this.score,
    totalXp: totalXp ?? this.totalXp,
    totalTasks: totalTasks ?? this.totalTasks,
    level: level ?? this.level,
    streakDays: streakDays ?? this.streakDays,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'groupId': groupId,
    'nickname': nickname,
    'avatarImagePath': avatarImagePath,
    'avatarColor': avatarColor.value,
    'score': score,
    'totalXp': totalXp,
    'totalTasks': totalTasks,
    'level': level,
    'streakDays': streakDays,
  };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: json['id'] as String,
    name: json['name'] as String,
    groupId: json['groupId'] as String? ?? '',
    nickname: json['nickname'] as String?,
    avatarImagePath: json['avatarImagePath'] as String?,
    avatarColor: Color(json['avatarColor'] as int),
    score: json['score'] as int? ?? 0,
    totalXp: json['totalXp'] as int? ?? 0,
    totalTasks: json['totalTasks'] as int? ?? 0,
    level: json['level'] as int? ?? 1,
    streakDays: json['streakDays'] as int? ?? 0,
  );
}

// ── Colores disponibles para avatar ──────────────────────────────────────────

const kAvatarColors = <Color>[
  AppColors.indigo500,
  AppColors.violet600,
  AppColors.categoryGardenFg,
  AppColors.categoryCleaningFg,
  AppColors.categoryCookingFg,
  AppColors.categoryLaundryFg,
  AppColors.streakOrange,
  AppColors.destructive,
];
