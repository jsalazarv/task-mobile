import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  static List<FamilyMember> _ranked(List<FamilyMember> members) {
    final sorted = List<FamilyMember>.of(members);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<FamilyMember>>(
      valueListenable: MemberService.instance.membersNotifier,
      builder: (context, members, _) => _SummaryContent(members: members),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.members});

  final List<FamilyMember> members;

  @override
  Widget build(BuildContext context) {
    final ranked = SummaryPage._ranked(members);
    final podium = ranked.take(3).toList();
    final rest   = ranked.skip(3).toList();

    return CustomScrollView(
      slivers: [
        // Hero card unificada: header + podio con gradiente
        SliverToBoxAdapter(
          child: _HeroPodiumCard(podium: podium),
        ),
        // Ranking del 4° en adelante
        if (rest.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _RankRow(member: rest[index], rank: index + 4),
              childCount: rest.length,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x2l)),
        const SliverToBoxAdapter(child: _AchievementsSection()),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x2l)),
      ],
    );
  }
}

// ── Hero card unificada (header + podio) ─────────────────────────────────────

class _HeroPodiumCard extends StatelessWidget {
  const _HeroPodiumCard({required this.podium});

  final List<FamilyMember> podium;

  static const _barHeights = {1: 110.0, 2: 80.0, 3: 62.0};

  String _weekRange(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final now    = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final months = [
      l10n.monthJanuary,   l10n.monthFebruary, l10n.monthMarch,
      l10n.monthApril,     l10n.monthMay,      l10n.monthJune,
      l10n.monthJuly,      l10n.monthAugust,   l10n.monthSeptember,
      l10n.monthOctober,   l10n.monthNovember, l10n.monthDecember,
    ];
    final start = '${monday.day} ${months[monday.month - 1]}';
    final end   = '${sunday.day} ${months[sunday.month - 1]}';
    return l10n.summaryWeekRange(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const heroRadius = BorderRadius.all(Radius.circular(AppRadius.x3l));
    const cardRadius = Radius.circular(AppRadius.x2l);

    final order = <({FamilyMember member, int rank, BorderRadius barRadius})>[
      if (podium.length > 1)
        (
          member: podium[1],
          rank: 2,
          barRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.x2l),
            topRight: Radius.circular(AppRadius.x2l),
            bottomLeft: cardRadius,
          ),
        ),
      (
        member: podium[0],
        rank: 1,
        barRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.x2l)),
      ),
      if (podium.length > 2)
        (
          member: podium[2],
          rank: 3,
          barRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.x2l),
            topRight: Radius.circular(AppRadius.x2l),
            bottomRight: cardRadius,
          ),
        ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.x2l, AppSpacing.lg, 0,
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
                  AppSpacing.x2l, AppSpacing.x2l, AppSpacing.x2l, AppSpacing.lg,
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
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.indigo200),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Text('🏆', style: TextStyle(fontSize: 40)),
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
                  AppSpacing.sm, AppSpacing.x2l, AppSpacing.sm, AppSpacing.x2l,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: order.map((entry) {
                    final barHeight = _barHeights[entry.rank] ?? 62.0;
                    return Expanded(
                      child: _PodiumColumn(
                        member: entry.member,
                        rank: entry.rank,
                        barHeight: barHeight,
                        barRadius: entry.barRadius,
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
    required this.member,
    required this.rank,
    required this.barHeight,
    required this.barRadius,
  });

  final FamilyMember member;
  final int rank;
  final double barHeight;
  final BorderRadius barRadius;

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          const Text('👑', style: TextStyle(fontSize: 22))
        else
          const SizedBox(height: 26),
        const SizedBox(height: 4),

        isFirst
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
                color: isFirst
                    ? AppColors.xpGold
                    : AppColors.white.withOpacity(0.75),
                fontWeight: isFirst ? FontWeight.w800 : FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),

        _PodiumBar(
          height: barHeight,
          rank: rank,
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
    required this.borderRadius,
  });

  final double height;
  final int rank;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isFirst
            ? AppColors.white.withOpacity(0.25)
            : AppColors.white.withOpacity(0.12),
        borderRadius: borderRadius,
        border: Border.all(
          color: AppColors.white.withOpacity(isFirst ? 0.4 : 0.2),
          width: 1,
        ),
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        '$rank°',
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
  const _RankRow({required this.member, required this.rank});

  final FamilyMember member;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
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
        border: isDark
            ? Border.all(color: AppColors.cardDarkBorder, width: 1)
            : null,
        boxShadow: isDark
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

    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glow = Tween<double>(begin: 6.0, end: 18.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (_, child) => Transform.scale(
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
  if (gradient == podiumGoldGradient)   return AppColors.xpGoldDark;        // #78350F
  if (gradient == podiumSilverGradient) return const Color(0xFF1E293B);     // slate-800
  return AppColors.streakOrangeLight;                                        // #FFF7ED (bronce)
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
      decoration: BoxDecoration(
        gradient: gradient,
        shape: BoxShape.circle,
      ),
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
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: 2,
      ),
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

    _scale = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (_, __) => Transform.translate(
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
    final paint = Paint()
      ..color = AppColors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path()
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
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const badges = <_BadgeData>[
      _BadgeData(icon: Icons.local_fire_department_rounded, title: 'Constante',  subtitle: '7 días seguidos',   unlocked: true),
      _BadgeData(icon: Icons.bolt_rounded,                  title: 'Veloz',      subtitle: '5 tareas en un día', unlocked: true),
      _BadgeData(icon: Icons.star_rounded,                  title: 'Perfecto',   subtitle: 'Semana 100%',        unlocked: false),
      _BadgeData(icon: Icons.groups_rounded,                title: 'Equipo',     subtitle: 'Todos participaron', unlocked: true),
    ];

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
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => _BadgeCard(data: badges[index]),
          ),
        ),
      ],
    );
  }
}

class _BadgeData {
  const _BadgeData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.unlocked,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool unlocked;
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.data});

  final _BadgeData data;

  static const _gold1     = Color(0xFFFCD34D);
  static const _gold2     = Color(0xFFF59E0B);
  static const _gold3     = Color(0xFFD97706);
  static const _goldShine = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: data.unlocked ? 1.0 : 0.35,
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: data.unlocked
              ? LinearGradient(
                  colors: [
                    _gold1.withOpacity(isDark ? 0.18 : 0.22),
                    _gold3.withOpacity(isDark ? 0.10 : 0.14),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: data.unlocked ? null : cs.surface,
          borderRadius: AppRadius.cardXl,
          border: data.unlocked
              ? Border.all(color: _gold2.withOpacity(0.5), width: 1.5)
              : Border.all(color: AppColors.cardDarkBorder, width: 1),
          boxShadow: data.unlocked
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: data.unlocked
                    ? const LinearGradient(
                        colors: [_gold1, _gold2, _gold3],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: data.unlocked ? null : cs.surfaceContainerHighest,
                shape: BoxShape.circle,
                boxShadow: data.unlocked
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
              child: data.unlocked
                  ? ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [_goldShine, _gold1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Icon(data.icon, size: 24, color: Colors.white),
                    )
                  : Icon(data.icon, size: 24, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              data.title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: data.unlocked ? _gold3 : cs.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              data.subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: data.unlocked
                        ? _gold2.withOpacity(0.85)
                        : cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
