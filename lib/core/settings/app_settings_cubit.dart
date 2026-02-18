import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hometasks/core/theme/app_colors.dart';

class AppSettingsState {
  const AppSettingsState({
    this.themeMode = ThemeMode.dark,
    this.locale = const Locale('es'),
    this.soundEnabled = true,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final bool soundEnabled;

  /// Color primario fijo según el tema activo: indigo400 en oscuro, indigo600 en claro.
  Color get effectivePrimaryColor =>
      themeMode == ThemeMode.dark ? AppColors.primaryDark : AppColors.primary;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? soundEnabled,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState());

  void setThemeMode(ThemeMode mode) => emit(state.copyWith(themeMode: mode));

  void setLocale(Locale locale) => emit(state.copyWith(locale: locale));

  void setSoundEnabled(bool enabled) => emit(state.copyWith(soundEnabled: enabled));
}
