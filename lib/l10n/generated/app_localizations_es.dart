// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'HomeTasks';

  @override
  String get loading => 'Cargando...';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get back => 'Regresar';

  @override
  String get or => 'o';

  @override
  String continueWith(String provider) {
    return 'Continuar con $provider';
  }

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle =>
      'Ingresa tus credenciales para acceder a tu cuenta';

  @override
  String get createAccount => 'Crea tu cuenta';

  @override
  String get registerSubtitle => 'Ingresa tu información para comenzar';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailPlaceholder => 'nombre@ejemplo.com';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordPlaceholder => '••••••••';

  @override
  String get name => 'Nombre completo';

  @override
  String get namePlaceholder => 'Juan Pérez';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get emailRequired => 'El correo electrónico es requerido';

  @override
  String get emailInvalid => 'Por favor ingresa un correo electrónico válido';

  @override
  String get passwordRequired => 'La contraseña es requerida';

  @override
  String passwordMinLength(int length) {
    return 'La contraseña debe tener al menos $length caracteres';
  }

  @override
  String get nameRequired => 'El nombre completo es requerido';

  @override
  String get networkError => 'Sin conexión a internet. Verifica tu red.';

  @override
  String get serverError =>
      'Algo salió mal de nuestro lado. Intenta más tarde.';

  @override
  String get unauthorizedError =>
      'Tu sesión ha expirado. Por favor inicia sesión de nuevo.';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado.';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get defaultHomeName => 'Mi Hogar';

  @override
  String get viewDay => 'Día';

  @override
  String get viewWeek => 'Semana';

  @override
  String get progressDay => 'Progreso del día';

  @override
  String get progressWeek => 'Progreso semanal';

  @override
  String tasksCompleted(int completed, int total) {
    return '$completed de $total tareas completadas';
  }

  @override
  String get newTask => 'Nueva tarea';

  @override
  String get taskFieldLabel => 'TAREA';

  @override
  String get taskFieldHint => 'Describe la tarea...';

  @override
  String get descFieldLabel => 'DESCRIPCIÓN';

  @override
  String get descFieldOptional => '(opcional)';

  @override
  String get descFieldHint => 'Agrega detalles o notas...';

  @override
  String get categoryLabel => 'CATEGORÍA';

  @override
  String get timeLabel => 'HORA';

  @override
  String get assigneeLabel => 'RESPONSABLE';

  @override
  String get assigneeHint => 'Nombre';

  @override
  String get addTask => 'Agregar tarea';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsSectionPreferences => 'PREFERENCIAS';

  @override
  String get settingsSectionAbout => 'ACERCA DE';

  @override
  String get settingsSectionLegal => 'LEGAL';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageEs => 'Español';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsSounds => 'Sonidos';

  @override
  String get settingsSoundsOn => 'Activados';

  @override
  String get settingsSoundsOff => 'Desactivados';

  @override
  String get settingsContact => 'Contáctanos';

  @override
  String get settingsContactSubtitle =>
      'Enviar comentarios o reportar problemas';

  @override
  String get settingsFollow => 'Síguenos';

  @override
  String get settingsFollowSubtitle => 'Redes sociales y novedades';

  @override
  String get settingsRate => 'Califícanos';

  @override
  String get settingsRateSubtitle => 'Déjanos tu opinión en la tienda';

  @override
  String get settingsTerms => 'Términos de servicio';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsVersion => 'Hogar v1.0.0';

  @override
  String get summaryTitle => 'Resumen';

  @override
  String get summarySubtitle => 'Esta semana';

  @override
  String summaryPoints(int points) {
    return '$points pts';
  }

  @override
  String summaryWeekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get taskDetailToday => 'Hoy';

  @override
  String get taskDetailStatusPending => 'Pendiente';

  @override
  String get taskDetailStatusPendingSubtitle =>
      'Marca como completada cuando termines';

  @override
  String get taskDetailStatusCompleted => 'Completada';

  @override
  String get taskDetailStatusCompletedSubtitle => 'Esta tarea ya fue realizada';

  @override
  String get taskDetailMarkCompleted => 'Marcar como completada';

  @override
  String get taskDetailMarkPending => 'Marcar como pendiente';

  @override
  String get monthJanuary => 'Enero';

  @override
  String get monthFebruary => 'Febrero';

  @override
  String get monthMarch => 'Marzo';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthMay => 'Mayo';

  @override
  String get monthJune => 'Junio';

  @override
  String get monthJuly => 'Julio';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthSeptember => 'Septiembre';

  @override
  String get monthOctober => 'Octubre';

  @override
  String get monthNovember => 'Noviembre';

  @override
  String get monthDecember => 'Diciembre';
}
