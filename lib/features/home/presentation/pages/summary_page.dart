import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/l10n/generated/app_localizations.dart';
import 'package:hometasks/core/models/task_category_model.dart';
import 'package:hometasks/core/services/achievement_calculator.dart';
import 'package:hometasks/core/services/group_service.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/services/task_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';
import 'package:go_router/go_router.dart';

/// Entrada del ranking con rango calculado según convención olímpica.
///
/// Los miembros con el mismo [score] comparten el mismo [rank].
/// El siguiente rango disponible salta en consecuencia (ej: 1°, 1°, 3°).
typedef _RankedEntry = ({FamilyMember member, int rank, bool isTied});

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  /// Ordena los miembros por score descendente y asigna rangos con empates.
  ///
  /// Convención olímpica: si dos miembros empatan en el puesto N, ambos
  /// reciben rango N y el siguiente rango disponible es N+2.
  static List<_RankedEntry> _assignRanks(List<FamilyMember> members) {
    final sorted = List<FamilyMember>.of(members)
      ..sort((a, b) => b.score.compareTo(a.score));

    final result = <_RankedEntry>[];
    var rank = 1;

    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i].score == sorted[i - 1].score) {
        // Empate: mismo rango que el anterior.
        result.add((member: sorted[i], rank: result.last.rank, isTied: true));
        // Marcar al anterior como empatado también.
        final prev = result[result.length - 2];
        result[result.length - 2] = (
          member: prev.member,
          rank: prev.rank,
          isTied: true,
        );
      } else {
        rank = i + 1;
        result.add((member: sorted[i], rank: rank, isTied: false));
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final activeGroupId =
        context.watch<AppSettingsCubit>().state.activeGroupId ?? '';

    return ValueListenableBuilder<List<FamilyMember>>(
      valueListenable: MemberService.instance.membersNotifier,
      builder: (context, allMembers, _) {
        final members =
            allMembers.where((m) => m.groupId == activeGroupId).toList();
        return _SummaryContent(members: members, activeGroupId: activeGroupId);
      },
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.members, required this.activeGroupId});

  final List<FamilyMember> members;
  final String activeGroupId;

  static DateTime _mondayOf(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const _EmptyMembersState();

    // Si nadie ha acumulado puntos todavía, mostrar estado vacío del podio.
    final allZero = members.every((m) => m.score == 0);

    // Datos para los logros: tareas de la semana actual del grupo.
    final weekStart = _mondayOf(DateTime.now());
    final weekTasks = TaskService.instance.forGroupAndWeek(
      activeGroupId,
      weekStart,
    );
    final groupCategories =
        GroupService.instance.findById(activeGroupId)?.categories ??
        DefaultCategories.all;

    final achievements = AchievementCalculator.calculate(
      members: members,
      weekTasks: weekTasks,
      groupCategories: groupCategories,
    );

    if (allZero) {
      return _NoPodiumYetState(achievements: achievements);
    }

    final ranked = SummaryPage._assignRanks(members);
    final podium = ranked.take(3).toList();
    final rest = ranked.skip(3).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _HeroPodiumCard(podium: podium)),
        if (rest.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _RankRow(entry: rest[index]),
              childCount: rest.length,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x2l)),
        SliverToBoxAdapter(
          child: _AchievementsSection(achievements: achievements),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x2l)),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyMembersState extends StatelessWidget {
  const _EmptyMembersState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.x2l,
              AppSpacing.lg,
              0,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.indigo700, AppColors.violet600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.x3l),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.indigo600.withOpacity(0.5),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: _BlobWidget(
                    size: 160,
                    opacity: 0.12,
                    durationMs: 3600,
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: -30,
                  child: _BlobWidget(
                    size: 120,
                    opacity: 0.08,
                    durationMs: 2900,
                    phaseOffset: 0.55,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x2l,
                    vertical: AppSpacing.x3l,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.emoji_events_outlined,
                            size: 38,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      Text(
                        'Sin miembros aún',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Agrega miembros a este grupo para ver el podio semanal y el ranking.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withOpacity(0.75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      // CTA para navegar a gestión de grupos/miembros
                      OutlinedButton.icon(
                        onPressed: () => context.push(AppRoutes.groups),
                        icon: const Icon(Icons.person_add_outlined),
                        label: const Text('Agregar miembro'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: BorderSide(
                            color: AppColors.white.withOpacity(0.6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.x2l,
                            vertical: AppSpacing.md,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.button,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Placeholder del ranking
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.x2l,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              'Ranking',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _RankRowPlaceholder(rank: index + 1),
            childCount: 3,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x2l)),
        // En el empty state de miembros no hay logros que calcular.
        const SliverToBoxAdapter(child: _AchievementsSection(achievements: [])),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x2l)),
      ],
    );
  }
}

// ── Estado vacío: hay miembros pero nadie tiene puntos aún ───────────────────

class _NoPodiumYetState extends StatelessWidget {
  const _NoPodiumYetState({required this.achievements});

  final List<AchievementResult> achievements;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.x2l,
              AppSpacing.lg,
              0,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.indigo700, AppColors.violet600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.x3l),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.indigo600.withOpacity(0.5),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x2l,
                vertical: AppSpacing.x3l,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.emoji_events_outlined,
                        size: 38,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  Text(
                    '¡El podio está vacío!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Completa tareas para ganar XP y aparecer en el podio semanal.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x2l)),
        SliverToBoxAdapter(
          child: _AchievementsSection(achievements: achievements),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x2l)),
      ],
    );
  }
}

class _RankRowPlaceholder extends StatelessWidget {
  const _RankRowPlaceholder({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.cardXl,
        border:
            isDark
                ? Border.all(color: AppColors.cardDarkBorder, width: 1)
                : null,
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank°',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant.withOpacity(0.35),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Avatar placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 60,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero card unificada (header + podio) ─────────────────────────────────────

class _HeroPodiumCard extends StatelessWidget {
  const _HeroPodiumCard({required this.podium});

  final List<_RankedEntry> podium;

  // Alturas de barra por posición visual (izq=2°, centro=1°, der=3°).
  // Se usa la posición en el layout, no el rango real, para mantener
  // proporciones aunque haya empates.
  static const _barHeights = {0: 80.0, 1: 110.0, 2: 62.0};

  String _weekRange(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final months = [
      l10n.monthJanuary,
      l10n.monthFebruary,
      l10n.monthMarch,
      l10n.monthApril,
      l10n.monthMay,
      l10n.monthJune,
      l10n.monthJuly,
      l10n.monthAugust,
      l10n.monthSeptember,
      l10n.monthOctober,
      l10n.monthNovember,
      l10n.monthDecember,
    ];
    final start = '${monday.day} ${months[monday.month - 1]}';
    final end = '${sunday.day} ${months[sunday.month - 1]}';
    return l10n.summaryWeekRange(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const heroRadius = BorderRadius.all(Radius.circular(AppRadius.x3l));
    const cardRadius = Radius.circular(AppRadius.x2l);

    // Layout visual: [2°, 1°, 3°] con sus border radius correspondientes.
    // Se usa posición visual (0=izq, 1=centro, 2=der), no el rango real.
    final order =
        <({_RankedEntry entry, int visualPos, BorderRadius barRadius})>[
          if (podium.length > 1)
            (
              entry: podium[1],
              visualPos: 0,
              barRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.x2l),
                topRight: Radius.circular(AppRadius.x2l),
                bottomLeft: cardRadius,
              ),
            ),
          (
            entry: podium[0],
            visualPos: 1,
            barRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.x2l),
            ),
          ),
          if (podium.length > 2)
            (
              entry: podium[2],
              visualPos: 2,
              barRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.x2l),
                topRight: Radius.circular(AppRadius.x2l),
                bottomRight: cardRadius,
              ),
            ),
        ];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.x2l,
        AppSpacing.lg,
        0,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.indigo700, AppColors.violet600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: heroRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo600.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Blob decorativo superior derecho
          Positioned(
            right: -20,
            top: -20,
            child: _BlobWidget(size: 160, opacity: 0.15, durationMs: 3600),
          ),
          // Blob decorativo inferior izquierdo
          Positioned(
            left: -30,
            bottom: -30,
            child: _BlobWidget(
              size: 120,
              opacity: 0.10,
              durationMs: 2900,
              phaseOffset: 0.55,
            ),
          ),
          // Contenido
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x2l,
                  AppSpacing.x2l,
                  AppSpacing.x2l,
                  AppSpacing.lg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.summaryTitle,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: AppColors.indigo200,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _weekRange(context),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.indigo200),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.emoji_events,
                      size: 40,
                      color: AppColors.xpGold,
                    ),
                  ],
                ),
              ),

              // Separador sutil
              Divider(
                color: AppColors.white.withOpacity(0.12),
                thickness: 1,
                height: 1,
              ),

              // ── Podio ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.x2l,
                  AppSpacing.sm,
                  AppSpacing.x2l,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:
                      order.map((item) {
                        final barHeight = _barHeights[item.visualPos] ?? 62.0;
                        return Expanded(
                          child: _PodiumColumn(
                            entry: item.entry,
                            isCenter: item.visualPos == 1,
                            barHeight: barHeight,
                            barRadius: item.barRadius,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Columna del podio ─────────────────────────────────────────────────────────

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.entry,
    required this.isCenter,
    required this.barHeight,
    required this.barRadius,
  });

  final _RankedEntry entry;

  /// Si está en la posición central (independiente del rango real).
  final bool isCenter;
  final double barHeight;
  final BorderRadius barRadius;

  @override
  Widget build(BuildContext context) {
    final member = entry.member;
    final rank = entry.rank;
    final isTied = entry.isTied;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCenter)
          const Icon(Icons.workspace_premium, size: 22, color: AppColors.xpGold)
        else
          const SizedBox(height: 26),
        const SizedBox(height: 4),

        isCenter
            ? _AnimatedRingAvatar(member: member, size: 56)
            : _MemberAvatar(
              member: member,
              size: 46,
              rankGradient: podiumGradientForRank(rank),
            ),
        const SizedBox(height: AppSpacing.sm),

        Text(
          member.name,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        _LevelBadge(level: member.level, compact: true),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.summaryPoints(member.score),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color:
                isCenter ? AppColors.xpGold : AppColors.white.withOpacity(0.75),
            fontWeight: isCenter ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        _PodiumBar(
          height: barHeight,
          rank: rank,
          isTied: isTied,
          borderRadius: barRadius,
        ),
      ],
    );
  }
}

// ── Barra del podio ───────────────────────────────────────────────────────────

class _PodiumBar extends StatelessWidget {
  const _PodiumBar({
    required this.height,
    required this.rank,
    required this.isTied,
    required this.borderRadius,
  });

  final double height;
  final int rank;
  final bool isTied;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final isTopCenter = rank == 1 && !isTied;
    final label = isTied ? '=$rank°' : '$rank°';

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color:
            isTopCenter
                ? AppColors.white.withOpacity(0.25)
                : AppColors.white.withOpacity(0.12),
        borderRadius: borderRadius,
        border: Border.all(
          color: AppColors.white.withOpacity(isTopCenter ? 0.4 : 0.2),
          width: 1,
        ),
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ── Fila de ranking (4° en adelante) ─────────────────────────────────────────

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry});

  final _RankedEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final member = entry.member;
    final rankLabel = entry.isTied ? '=${entry.rank}°' : '${entry.rank}°';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.cardXl,
        border:
            isDark
                ? Border.all(color: AppColors.cardDarkBorder, width: 1)
                : null,
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              rankLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _MemberAvatar(member: member, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                _LevelBadge(level: member.level, compact: false),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (member.streakDays > 0) ...[
            _StreakBadge(days: member.streakDays),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            l10n.summaryPoints(member.score),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.xpGold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar con efecto palpitante (1° lugar) ───────────────────────────────────

class _AnimatedRingAvatar extends StatefulWidget {
  const _AnimatedRingAvatar({required this.member, required this.size});

  final FamilyMember member;
  final double size;

  @override
  State<_AnimatedRingAvatar> createState() => _AnimatedRingAvatarState();
}

class _AnimatedRingAvatarState extends State<_AnimatedRingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glow = Tween<double>(
      begin: 6.0,
      end: 18.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder:
          (_, child) => Transform.scale(
            scale: _scale.value,
            child: Container(
              width: widget.size + 6,
              height: widget.size + 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: podiumGoldGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.xpGold.withOpacity(0.65),
                    blurRadius: _glow.value,
                    spreadRadius: _glow.value * 0.2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2.5),
              child: child,
            ),
          ),
      child: _MemberAvatar(
        member: widget.member,
        size: widget.size,
        rankGradient: podiumGoldGradient,
      ),
    );
  }
}

// ── Avatar compartido ─────────────────────────────────────────────────────────

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.member,
    required this.size,
    this.rankGradient,
  });

  final FamilyMember member;
  final double size;

  /// Cuando se pasa, el borde y la inicial usan este gradiente en lugar
  /// del color personal del miembro.
  final LinearGradient? rankGradient;

  @override
  Widget build(BuildContext context) {
    final gradient = rankGradient;

    if (gradient != null) {
      return _GradientAvatar(
        member: member,
        size: size,
        gradient: gradient,
        initialColor: _initialColorForGradient(gradient),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: member.avatarColor.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(color: member.avatarColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        member.initial,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
          color: member.avatarColor,
        ),
      ),
    );
  }
}

/// Elige el color de la inicial según la luminosidad del gradiente de podio.
///
/// - Oro y plata tienen fondos claros → inicial oscura.
/// - Bronce tiene fondo oscuro → inicial clara.
Color _initialColorForGradient(LinearGradient gradient) {
  if (gradient == podiumGoldGradient) return AppColors.xpGoldDark; // #78350F
  if (gradient == podiumSilverGradient)
    return const Color(0xFF1E293B); // slate-800
  return AppColors.streakOrangeLight; // #FFF7ED (bronce)
}

/// Avatar con borde e inicial renderizados con gradiente de podio.
class _GradientAvatar extends StatelessWidget {
  const _GradientAvatar({
    required this.member,
    required this.size,
    required this.gradient,
    required this.initialColor,
  });

  final FamilyMember member;
  final double size;
  final LinearGradient gradient;

  /// Color sólido de contraste para la inicial, elegido por el llamador
  /// según la luminosidad del gradiente (oscuro para oro/plata, claro para bronce).
  final Color initialColor;

  static const _borderWidth = 2.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle),
      padding: const EdgeInsets.all(_borderWidth),
      child: Container(
        decoration: BoxDecoration(
          color: gradient.colors.first.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          member.initial,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w900,
            color: initialColor,
          ),
        ),
      ),
    );
  }
}

// ── Badges ────────────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.compact});

  final int level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.xpGoldLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.xpGold.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('⚡', style: TextStyle(fontSize: compact ? 9 : 11)),
          const SizedBox(width: 2),
          Text(
            'Nv.$level',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.xpGold,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 9 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.streakOrangeLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.streakOrange.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 2),
          Text(
            '$days',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.streakOrange,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Blob decorativo animado ───────────────────────────────────────────────────

class _BlobWidget extends StatefulWidget {
  const _BlobWidget({
    required this.size,
    required this.opacity,
    this.floatOffset = 14.0,
    this.durationMs = 3200,
    this.phaseOffset = 0.0,
  });

  final double size;
  final double opacity;
  final double floatOffset;
  final int durationMs;
  final double phaseOffset;

  @override
  State<_BlobWidget> createState() => _BlobWidgetState();
}

class _BlobWidgetState extends State<_BlobWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    )..repeat(reverse: true);

    if (widget.phaseOffset > 0) {
      _controller.value = widget.phaseOffset;
    }

    _float = Tween<double>(
      begin: -widget.floatOffset,
      end: widget.floatOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scale = Tween<double>(
      begin: 0.90,
      end: 1.10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder:
          (_, __) => Transform.translate(
            offset: Offset(0, _float.value),
            child: Transform.scale(
              scale: _scale.value,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _BlobPainter(opacity: widget.opacity),
              ),
            ),
          ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.white.withOpacity(opacity)
          ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path =
        Path()
          ..moveTo(w * 0.5, 0)
          ..cubicTo(w * 0.9, 0, w, h * 0.3, w, h * 0.55)
          ..cubicTo(w, h * 0.85, w * 0.75, h, w * 0.45, h)
          ..cubicTo(w * 0.15, h, 0, h * 0.8, 0, h * 0.55)
          ..cubicTo(0, h * 0.25, w * 0.15, 0, w * 0.5, 0)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.opacity != opacity;
}

// ── Sección de Logros ─────────────────────────────────────────────────────────

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.achievements});

  final List<AchievementResult> achievements;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Logros de la semana',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          // La altura aumenta para acomodar los avatares de los ganadores.
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder:
                (context, index) => _BadgeCard(result: achievements[index]),
          ),
        ),
      ],
    );
  }
}

// ── Badge Card ────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.result});

  final AchievementResult result;

  static const _gold1 = Color(0xFFFCD34D);
  static const _gold2 = Color(0xFFF59E0B);
  static const _gold3 = Color(0xFFD97706);
  static const _goldShine = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unlocked = result.unlocked;

    return Opacity(
      opacity: unlocked ? 1.0 : 0.35,
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient:
              unlocked
                  ? LinearGradient(
                    colors: [
                      _gold1.withOpacity(isDark ? 0.18 : 0.22),
                      _gold3.withOpacity(isDark ? 0.10 : 0.14),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: unlocked ? null : cs.surface,
          borderRadius: AppRadius.cardXl,
          border:
              unlocked
                  ? Border.all(color: _gold2.withOpacity(0.5), width: 1.5)
                  : Border.all(color: AppColors.cardDarkBorder, width: 1),
          boxShadow:
              unlocked
                  ? [
                    BoxShadow(
                      color: _gold2.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ícono ──────────────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient:
                    unlocked
                        ? const LinearGradient(
                          colors: [_gold1, _gold2, _gold3],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                color: unlocked ? null : cs.surfaceContainerHighest,
                shape: BoxShape.circle,
                boxShadow:
                    unlocked
                        ? [
                          BoxShadow(
                            color: _gold2.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                        : null,
              ),
              alignment: Alignment.center,
              child:
                  unlocked
                      ? ShaderMask(
                        shaderCallback:
                            (bounds) => const LinearGradient(
                              colors: [_goldShine, _gold1],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: Icon(
                          result.def.icon,
                          size: 22,
                          color: Colors.white,
                        ),
                      )
                      : Icon(
                        result.def.icon,
                        size: 22,
                        color: cs.onSurfaceVariant,
                      ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // ── Título y subtítulo ─────────────────────────────────────────
            Text(
              result.def.title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: unlocked ? _gold3 : cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              result.def.subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color:
                    unlocked ? _gold2.withOpacity(0.85) : cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // ── Avatares de los ganadores ─────────────────────────────────
            if (unlocked) ...[
              const SizedBox(height: AppSpacing.xs),
              _EarnerAvatars(earners: result.earners),
            ] else
              const SizedBox(height: AppSpacing.lg + AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}

// ── Fila de avatares de los miembros que lograron la insignia ─────────────────

class _EarnerAvatars extends StatelessWidget {
  const _EarnerAvatars({required this.earners});

  final List<FamilyMember> earners;

  static const _avatarSize = 20.0;
  static const _maxVisible = 3;

  @override
  Widget build(BuildContext context) {
    final visible = earners.take(_maxVisible).toList();
    final overflow = earners.length - _maxVisible;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...visible.map(
          (m) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Container(
              width: _avatarSize,
              height: _avatarSize,
              decoration: BoxDecoration(
                color: m.avatarColor.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(color: m.avatarColor, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                m.initial,
                style: TextStyle(
                  fontSize: _avatarSize * 0.42,
                  fontWeight: FontWeight.w800,
                  color: m.avatarColor,
                ),
              ),
            ),
          ),
        ),
        if (overflow > 0) ...[
          const SizedBox(width: 2),
          Text(
            '+$overflow',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ],
    );
  }
}
