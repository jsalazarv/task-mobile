import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsState {
  const AppSettingsState({
    this.themeMode = ThemeMode.dark,
    this.locale = const Locale('es'),
    this.soundEnabled = true,
    this.homeName = '',
    this.onboardingComplete = false,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final bool soundEnabled;
  final String homeName;
  final bool onboardingComplete;

  /// Color primario fijo según el tema activo: indigo400 en oscuro, indigo600 en claro.
  Color get effectivePrimaryColor =>
      themeMode == ThemeMode.dark ? AppColors.primaryDark : AppColors.primary;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? soundEnabled,
    String? homeName,
    bool? onboardingComplete,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      homeName: homeName ?? this.homeName,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState());

  static const _keyTheme = 'settings_theme';
  static const _keyLocale = 'settings_locale';
  static const _keySound = 'settings_sound';
  static const _keyHomeName = 'settings_home_name';
  static const _keyOnboarding = 'settings_onboarding_complete';

  /// Carga preferencias persistidas desde SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_keyTheme) ?? ThemeMode.dark.index;
    final localeCode = prefs.getString(_keyLocale) ?? 'es';
    final soundEnabled = prefs.getBool(_keySound) ?? true;
    final homeName = prefs.getString(_keyHomeName) ?? '';
    final onboardingComplete = prefs.getBool(_keyOnboarding) ?? false;

    emit(AppSettingsState(
      themeMode: ThemeMode.values[themeIndex],
      locale: Locale(localeCode),
      soundEnabled: soundEnabled,
      homeName: homeName,
      onboardingComplete: onboardingComplete,
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
  }

  Future<void> setLocale(Locale locale) async {
    emit(state.copyWith(locale: locale));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    emit(state.copyWith(soundEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, enabled);
  }

  Future<void> setHomeName(String name) async {
    emit(state.copyWith(homeName: name));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHomeName, name);
  }

  Future<void> completeOnboarding(String homeName) async {
    emit(state.copyWith(homeName: homeName, onboardingComplete: true));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHomeName, homeName);
    await prefs.setBool(_keyOnboarding, true);
  }
}
