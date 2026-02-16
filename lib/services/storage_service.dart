import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Storage Service
/// Manages local data persistence using SharedPreferences
class StorageService {
  static late SharedPreferences _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============ Token Management ============

  /// Save authentication token
  static Future<bool> setToken(String token) async {
    return await _prefs.setString(AppConfig.tokenKey, token);
  }

  /// Get authentication token
  static String? getToken() {
    return _prefs.getString(AppConfig.tokenKey);
  }

  /// Save refresh token
  static Future<bool> setRefreshToken(String token) async {
    return await _prefs.setString(AppConfig.refreshTokenKey, token);
  }

  /// Get refresh token
  static String? getRefreshToken() {
    return _prefs.getString(AppConfig.refreshTokenKey);
  }

  /// Clear all auth tokens
  static Future<bool> clearTokens() async {
    await _prefs.remove(AppConfig.tokenKey);
    await _prefs.remove(AppConfig.refreshTokenKey);
    return true;
  }

  // ============ User Data Management ============

  /// Save user data as JSON string
  static Future<bool> setUserData(String userData) async {
    return await _prefs.setString(AppConfig.userKey, userData);
  }

  /// Get user data
  static String? getUserData() {
    return _prefs.getString(AppConfig.userKey);
  }

  /// Clear user data
  static Future<bool> clearUserData() async {
    return await _prefs.remove(AppConfig.userKey);
  }

  // ============ Login State Management ============

  /// Set login state
  static Future<bool> setLoggedIn(bool value) async {
    return await _prefs.setBool(AppConfig.isLoggedInKey, value);
  }

  /// Get login state
  static bool isLoggedIn() {
    return _prefs.getBool(AppConfig.isLoggedInKey) ?? false;
  }

  // ============ Preference Management ============

  /// Save string preference
  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get string preference
  static String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save boolean preference
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get boolean preference
  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Save integer preference
  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Get integer preference
  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Remove preference
  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all preferences
  static Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// Check if key exists
  static bool contains(String key) {
    return _prefs.containsKey(key);
  }

  /// Get all preferences
  static Map<String, dynamic> getAll() {
    return _prefs.getKeys().fold({}, (map, key) {
      map[key] = _prefs.get(key);
      return map;
    });
  }
}
