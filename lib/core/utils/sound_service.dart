import 'package:audioplayers/audioplayers.dart';

enum _TaskCompleteSound {
  archievement('sounds/archievement.mp3'),
  archievementBack('sounds/archievement.back.mp3');

  const _TaskCompleteSound(this.path);
  final String path;
}

/// Servicio de audio de la app. Gestiona la reproducción de efectos de sonido.
///
/// Se accede vía [SoundService.instance] — singleton lazy inicializado una
/// sola vez durante el ciclo de vida de la app.
class SoundService {
  SoundService._()
      : _player = AudioPlayer(),
        _switchPlayer = AudioPlayer();

  static final SoundService instance = SoundService._();

  final AudioPlayer _player;
  final AudioPlayer _switchPlayer;

  // ── Cambia aquí para probar el otro sonido ────────────────────────────────
  static const _activeSound = _TaskCompleteSound.archievement;
  // ─────────────────────────────────────────────────────────────────────────

  /// Reproduce el efecto de sonido al completar una tarea.
  /// No hace nada si [enabled] es false.
  /// Falla silenciosamente para no interrumpir el flujo del usuario.
  Future<void> playTaskComplete({required bool enabled}) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(_activeSound.path));
    } catch (_) {
      // El audio nunca debe romper la experiencia del usuario.
    }
  }

  /// Reproduce el sonido de toggle para los switches de la app.
  /// Solo suena si [enabled] es true (respeta la preferencia del usuario).
  Future<void> playSwitch({required bool enabled}) async {
    if (!enabled) return;
    try {
      await _switchPlayer.stop();
      await _switchPlayer.play(AssetSource('sounds/switch.mp3'));
    } catch (_) {
      // El audio nunca debe romper la experiencia del usuario.
    }
  }

  /// Libera los recursos de los players. Llamar al cerrar la app si es necesario.
  Future<void> dispose() async {
    await _player.dispose();
    await _switchPlayer.dispose();
  }
}
