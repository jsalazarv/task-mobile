import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SharedPrefsService {
  SharedPrefsService(this._prefs);

  final SharedPreferences _prefs;

  // Keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  // Auth Token
  Future<void> setAuthToken(String token) async {
    await _prefs.setString(_keyAuthToken, token);
  }

  String? getAuthToken() {
    return _prefs.getString(_keyAuthToken);
  }

  Future<void> removeAuthToken() async {
    await _prefs.remove(_keyAuthToken);
  }

  // Refresh Token
  Future<void> setRefreshToken(String token) async {
    await _prefs.setString(_keyRefreshToken, token);
  }

  String? getRefreshToken() {
    return _prefs.getString(_keyRefreshToken);
  }

  Future<void> removeRefreshToken() async {
    await _prefs.remove(_keyRefreshToken);
  }

  // User ID
  Future<void> setUserId(String userId) async {
    await _prefs.setString(_keyUserId, userId);
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  Future<void> removeUserId() async {
    await _prefs.remove(_keyUserId);
  }

  // Theme Mode
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  String? getThemeMode() {
    return _prefs.getString(_keyThemeMode);
  }

  // Language Code
  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(_keyLanguageCode, code);
  }

  String? getLanguageCode() {
    return _prefs.getString(_keyLanguageCode);
  }

  // Onboarding
  Future<void> setOnboardingCompleted({required bool completed}) async {
    await _prefs.setBool(_keyOnboardingCompleted, completed);
  }

  bool getOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  // Clear all data (useful for logout)
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Clear auth data only
  Future<void> clearAuthData() async {
    await Future.wait([
      removeAuthToken(),
      removeRefreshToken(),
      removeUserId(),
    ]);
  }
}

@module
abstract class SharedPrefsModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
