import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/utils/sound_service.dart';

/// Lanza la animación +XP centrada en pantalla.
/// Si [isLastTask] es true, muestra el badge dorado de medalla en lugar del badge normal.
void showXpBurst(BuildContext context, {bool isLastTask = false}) {
  final soundEnabled = context.read<AppSettingsCubit>().state.soundEnabled;
  SoundService.instance.playTaskComplete(enabled: soundEnabled);

  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _XpBurstOverlay(
      isLastTask: isLastTask,
      onDone: entry.remove,
    ),
  );

  overlay.insert(entry);
}

// ── Overlay principal ─────────────────────────────────────────────────────────

class _XpBurstOverlay extends StatefulWidget {
  const _XpBurstOverlay({required this.isLastTask, required this.onDone});

  final bool isLastTask;
  final VoidCallback onDone;

  @override
  State<_XpBurstOverlay> createState() => _XpBurstOverlayState();
}

class _XpBurstOverlayState extends State<_XpBurstOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _offsetY;

  // Duración más larga para el badge de última tarea.
  Duration get _duration => widget.isLastTask
      ? const Duration(milliseconds: 2200)
      : const Duration(milliseconds: 1100);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.15)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 72),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _offsetY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 24.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 55),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -20.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);

    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Stack(
          children: [
            // Fondo semitransparente solo para badge de última tarea
            if (widget.isLastTask)
              Positioned.fill(
                child: Opacity(
                  opacity: (_opacity.value * 0.55).clamp(0.0, 1.0),
                  child: const ColoredBox(color: Colors.black),
                ),
              ),

            // Partículas
            ..._buildParticles(screenSize),

            // Badge central
            Positioned(
              left: 0,
              right: 0,
              top: screenSize.height / 2 -
                  (widget.isLastTask ? 130 : 60) +
                  _offsetY.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: widget.isLastTask
                      ? const _LastTaskBadge()
                      : const _XpBadge(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles(Size screenSize) {
    final count = widget.isLastTask ? 16 : 8;
    const cx = 0.5;
    const cy = 0.45;

    final colors = widget.isLastTask
        ? [
            AppColors.xpGold,
            AppColors.xpGoldLight,
            const Color(0xFFFCD34D),
            const Color(0xFFF59E0B),
          ]
        : [
            AppColors.indigo400,
            AppColors.violet400,
            AppColors.xpGold,
            AppColors.indigo200,
          ];

    return List.generate(count, (i) {
      final angle = (i / count) * 2 * math.pi;
      final progress = _controller.value;

      final particleProgress = Curves.easeOut.transform(
        (progress * 1.4).clamp(0.0, 1.0),
      );
      final fadeOut = (1.0 - (progress * 2.0).clamp(0.0, 1.0));

      final maxRadius = widget.isLastTask
          ? screenSize.width * 0.55
          : screenSize.width * 0.38;
      final radius = particleProgress * maxRadius;
      final dx = screenSize.width * cx + math.cos(angle) * radius;
      final dy = screenSize.height * cy + math.sin(angle) * radius;
      final baseSize = widget.isLastTask ? 9.0 : 6.0;
      final particleSize =
          (baseSize + (i % 3) * 3.0) * (1.0 - particleProgress * 0.4);

      final color = colors[i % colors.length];

      return Positioned(
        left: dx - particleSize / 2,
        top: dy - particleSize / 2,
        child: Opacity(
          opacity: (fadeOut * 0.85).clamp(0.0, 1.0),
          child: Container(
            width: particleSize,
            height: particleSize,
            decoration: BoxDecoration(
              color: color,
              shape: i.isEven ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: i.isEven ? null : BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.7),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ── Badge normal (+10 XP) ─────────────────────────────────────────────────────

class _XpBadge extends StatelessWidget {
  const _XpBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.indigo500, AppColors.violet600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo500.withOpacity(0.6),
              blurRadius: 36,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.violet600.withOpacity(0.35),
              blurRadius: 60,
              spreadRadius: 8,
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+10',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
                height: 1.0,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'XP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge última tarea (medalla dorada hexagonal) ─────────────────────────────

class _LastTaskBadge extends StatelessWidget {
  const _LastTaskBadge();

  static const _gold1 = Color(0xFFFCD34D);
  static const _gold2 = Color(0xFFF59E0B);
  static const _gold3 = Color(0xFFD97706);
  static const _goldShine = Color(0xFFFFFBEB);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow exterior
            CustomPaint(
              size: const Size(220, 260),
              painter: _HexGlowPainter(),
            ),
            // Hexágono dorado con gradiente
            CustomPaint(
              size: const Size(200, 230),
              painter: _HexBadgePainter(
                fillColors: [_gold1, _gold2, _gold3],
                strokeColor: _goldShine,
              ),
            ),
            // Contenido interior: llama + texto centrados en el hexágono
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFFBEB), Color(0xFFF59E0B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_goldShine, _gold2],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: const Text(
                      '¡LISTO!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFFBEB), Color(0xFFF59E0B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: const Text(
                      'TODO COMPLETADO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hexágono painter ──────────────────────────────────────────────────────────

class _HexBadgePainter extends CustomPainter {
  const _HexBadgePainter({
    required this.fillColors,
    required this.strokeColor,
  });

  final List<Color> fillColors;
  final Color strokeColor;

  Path _hexPath(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) * 0.92;
    const cornerRadius = 18.0;

    // Calcula los 6 vértices del hexágono
    final vertices = List.generate(6, (i) {
      final angle = math.pi / 6 + (math.pi / 3) * i;
      return Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
    });

    final path = Path();
    for (var i = 0; i < 6; i++) {
      final curr = vertices[i];
      final next = vertices[(i + 1) % 6];
      final prev = vertices[(i + 5) % 6];

      // Vector unitario desde vértice hacia el lado anterior y siguiente
      final toPrev = (prev - curr);
      final toNext = (next - curr);
      final toPrevLen = toPrev.distance;
      final toNextLen = toNext.distance;

      final p1 = curr + toPrev / toPrevLen * cornerRadius;
      final p2 = curr + toNext / toNextLen * cornerRadius;

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, p2.dx, p2.dy);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _hexPath(size);

    // Relleno con gradiente
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: fillColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, fillPaint);

    // Borde brillante
    final strokePaint = Paint()
      ..color = strokeColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(path, strokePaint);

    // Reflejo interior sutil
    final shinePaint = Paint()
      ..shader = LinearGradient(
        colors: [strokeColor.withOpacity(0.35), Colors.transparent],
        begin: Alignment.topLeft,
        end: Alignment.center,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, shinePaint);
  }

  @override
  bool shouldRepaint(_HexBadgePainter old) => false;
}

class _HexGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final glowPaint = Paint()
      ..color = const Color(0xFFF59E0B).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(Offset(cx, cy + 10), size.width * 0.42, glowPaint);
  }

  @override
  bool shouldRepaint(_HexGlowPainter old) => false;
}


