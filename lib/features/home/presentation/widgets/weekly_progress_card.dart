import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hometasks/l10n/generated/app_localizations.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/view_mode_selector.dart';

class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({
    required this.completed,
    required this.total,
    required this.viewMode,
    super.key,
  });

  final int completed;
  final int total;
  final ViewMode viewMode;

  double get _progress   => total == 0 ? 0 : completed / total;
  int    get _percentage => (_progress * 100).round();
  bool   get _isComplete => completed == total && total > 0;
  int    get _xp         => completed * 10;
  int    get _xpTotal    => total * 10;

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context)!;
    final title = viewMode == ViewMode.day ? l10n.progressDay : l10n.progressWeek;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.indigo700, AppColors.violet600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo600.withOpacity(0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Blob decorativo en la esquina inferior derecha
          Positioned(
            right: -30,
            bottom: -30,
            child: _BlobPainterWidget(size: 180, durationMs: 3400),
          ),
          // Segundo blob más pequeño arriba a la derecha
          Positioned(
            right: 60,
            top: -40,
            child: _BlobPainterWidget(
              size: 110,
              opacity: 0.15,
              durationMs: 2800,
              phaseOffset: 0.5,
            ),
          ),
          // Contenido con glass
          Positioned.fill(
            child: ClipRRect(
              borderRadius: AppRadius.card,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: _CardContent(
                  title: title,
                  completed: completed,
                  total: total,
                  percentage: _percentage,
                  progress: _progress,
                  isComplete: _isComplete,
                  xp: _xp,
                  xpTotal: _xpTotal,
                  l10n: l10n,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.title,
    required this.completed,
    required this.total,
    required this.percentage,
    required this.progress,
    required this.isComplete,
    required this.xp,
    required this.xpTotal,
    required this.l10n,
  });

  final String title;
  final int completed;
  final int total;
  final int percentage;
  final double progress;
  final bool isComplete;
  final int xp;
  final int xpTotal;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x2l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + porcentaje
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.75),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey('$percentage'),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? AppColors.xpGold
                        : AppColors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isComplete
                              ? AppColors.white
                              : AppColors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Número grande de tareas completadas
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$completed',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 6),
                child: Text(
                  '/ $total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.tasksCompleted(completed, total),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withOpacity(0.65),
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Barra de progreso + XP
          Row(
            children: [
              Expanded(child: _XpBar(progress: progress)),
              const SizedBox(width: AppSpacing.md),
              Text(
                '$xp / $xpTotal XP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isComplete
                          ? AppColors.xpGold
                          : AppColors.white.withOpacity(0.75),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Barra XP ─────────────────────────────────────────────────────────────────

class _XpBar extends StatelessWidget {
  const _XpBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: SizedBox(
        height: 6,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, value, __) => Stack(
            children: [
              Container(color: AppColors.white.withOpacity(0.2)),
              FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Blob decorativo animado ───────────────────────────────────────────────────

class _BlobPainterWidget extends StatefulWidget {
  const _BlobPainterWidget({
    required this.size,
    this.opacity = 0.22,
    this.floatOffset = 12.0,
    this.durationMs = 3200,
    this.phaseOffset = 0.0,
  });

  final double size;
  final double opacity;

  /// Amplitud máxima de flotación vertical en píxeles.
  final double floatOffset;

  /// Duración de un ciclo completo de animación.
  final int durationMs;

  /// Desfase de fase (0.0–1.0) para que los blobs no se muevan sincronizados.
  final double phaseOffset;

  @override
  State<_BlobPainterWidget> createState() => _BlobPainterWidgetState();
}

class _BlobPainterWidgetState extends State<_BlobPainterWidget>
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

    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
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
      ..moveTo(w * 0.5, h * 0.0)
      ..cubicTo(w * 0.9, h * 0.0, w * 1.0, h * 0.3, w * 1.0, h * 0.55)
      ..cubicTo(w * 1.0, h * 0.85, w * 0.75, h * 1.0, w * 0.45, h * 1.0)
      ..cubicTo(w * 0.15, h * 1.0, w * 0.0, h * 0.8, w * 0.0, h * 0.55)
      ..cubicTo(w * 0.0, h * 0.25, w * 0.15, h * 0.0, w * 0.5, h * 0.0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.opacity != opacity;
}

// ── Shimmer de brillo (reutilizable) ─────────────────────────────────────────

class _ShimmerOverlay extends StatefulWidget {
  const _ShimmerOverlay();

  @override
  State<_ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<_ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
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
      builder: (_, __) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-1.5 + _controller.value * 4, 0),
          end: Alignment(-0.5 + _controller.value * 4, 0),
          colors: const [
            Colors.transparent,
            Colors.white24,
            Colors.transparent,
          ],
        ).createShader(bounds),
        blendMode: BlendMode.srcATop,
        child: Container(color: Colors.white),
      ),
    );
  }
}

// Exportado para uso en summary_page (barra XP de shimmer)
class XpProgressBar extends StatelessWidget {
  const XpProgressBar({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: SizedBox(
        height: 12,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (_, value, __) => Stack(
            children: [
              Container(color: cs.surfaceContainerHighest),
              FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.indigo600, AppColors.violet600],
                    ),
                  ),
                ),
              ),
              if (value > 0.05)
                FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: const _ShimmerOverlay(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


