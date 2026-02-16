import 'dart:convert';
import 'api_service.dart';
import 'storage_service.dart';
import '../models/user.dart';

/// Authentication Service
/// Handles all authentication-related operations
class AuthService {
  static final AuthService _instance = AuthService._internal();
  final ApiService _api = ApiService();

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  // ============ Login & Registration ============

  /// Login user with email and password
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _api.login(email, password);
      if (response['token'] != null) {
        // Save token
        await StorageService.setToken(response['token']);
        
        // Save user data if available
        if (response['user'] != null) {
          await StorageService.setUserData(jsonEncode(response['user']));
        }

        // Set login state
        await StorageService.setLoggedIn(true);
        
        return response;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Register new user
  Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    try {
      final response = await _api.register(userData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await StorageService.clearTokens();
      await StorageService.clearUserData();
      await StorageService.setLoggedIn(false);
    } catch (e) {
      rethrow;
    }
  }

  // ============ Token Management ============

  /// Get current auth token
  String? getToken() {
    return StorageService.getToken();
  }

  /// Check if token exists and is not empty
  bool hasValidToken() {
    final token = StorageService.getToken();
    return token != null && token.isNotEmpty;
  }

  // ============ User Management ============

  /// Get current logged-in user from storage
  User? getCurrentUser() {
    String? userJson = StorageService.getUserData();
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson);
        return User.fromMap(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save user data
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      return await StorageService.setUserData(jsonEncode(userData));
    } catch (e) {
      rethrow;
    }
  }

  // ============ Auth State Checks ============

  /// Check if user is logged in
  bool isLoggedIn() {
    return StorageService.isLoggedIn() && hasValidToken();
  }

  /// Sync user data from storage
  Future<bool> syncUserData() async {
    try {
      return getCurrentUser() != null;
    } catch (e) {
      return false;
    }
  }

  /// Refresh authentication state
  Future<bool> refreshAuthState() async {
    try {
      // Check if token and user data exist
      bool hasToken = hasValidToken();
      bool hasUser = getCurrentUser() != null;
      return hasToken && hasUser;
    } catch (e) {
      return false;
    }
  }
}
