import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyLastConversionPath = 'last_conversion_path';
  static const String _keyConversionCount = 'conversion_count';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyAppVersion = 'app_version';
  
  static SharedPreferences? _prefs;
  
  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    await _prefs?.setString(_keyUserEmail, email);
  }
  
  /// Get saved user email
  static String? getUserEmail() {
    return _prefs?.getString(_keyUserEmail);
  }
  
  /// Save authentication status
  static Future<void> saveAuthenticationStatus(bool isAuthenticated) async {
    await _prefs?.setBool(_keyIsAuthenticated, isAuthenticated);
  }
  
  /// Get authentication status
  static bool getAuthenticationStatus() {
    return _prefs?.getBool(_keyIsAuthenticated) ?? false;
  }
  
  /// Save last conversion path
  static Future<void> saveLastConversionPath(String path) async {
    await _prefs?.setString(_keyLastConversionPath, path);
  }
  
  /// Get last conversion path
  static String? getLastConversionPath() {
    return _prefs?.getString(_keyLastConversionPath);
  }
  
  /// Increment conversion count
  static Future<void> incrementConversionCount() async {
    final currentCount = getConversionCount();
    await _prefs?.setInt(_keyConversionCount, currentCount + 1);
  }
  
  /// Get conversion count
  static int getConversionCount() {
    return _prefs?.getInt(_keyConversionCount) ?? 0;
  }
  
  /// Check if this is first launch
  static bool isFirstLaunch() {
    return _prefs?.getBool(_keyFirstLaunch) ?? true;
  }
  
  /// Set first launch completed
  static Future<void> setFirstLaunchCompleted() async {
    await _prefs?.setBool(_keyFirstLaunch, false);
  }
  
  /// Save app version
  static Future<void> saveAppVersion(String version) async {
    await _prefs?.setString(_keyAppVersion, version);
  }
  
  /// Get saved app version
  static String? getSavedAppVersion() {
    return _prefs?.getString(_keyAppVersion);
  }
  
  /// Clear all user data (logout)
  static Future<void> clearUserData() async {
    await _prefs?.remove(_keyUserEmail);
    await _prefs?.remove(_keyIsAuthenticated);
    await _prefs?.remove(_keyLastConversionPath);
  }
  
  /// Clear all app data
  static Future<void> clearAllData() async {
    await _prefs?.clear();
  }
  
  /// Get all settings as Map for debugging
  static Map<String, dynamic> getAllSettings() {
    return {
      'user_email': getUserEmail(),
      'is_authenticated': getAuthenticationStatus(),
      'last_conversion_path': getLastConversionPath(),
      'conversion_count': getConversionCount(),
      'first_launch': isFirstLaunch(),
      'app_version': getSavedAppVersion(),
    };
  }
}