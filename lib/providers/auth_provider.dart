import 'dart:convert';

import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../config/routes.dart';

class AuthProvider extends GetxController {
  final AuthService _authService = AuthService();

  final currentUser = Rx<User?>(null);
  final isLoading = RxBool(true);
  final isLoggedIn = RxBool(false);
  final errorMessage = RxString('');

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  @override
  void onReady() {
    super.onReady();
    // Navigate to appropriate route after auth check
    ever(isLoading, (loading) {
      if (!loading) {
        if (isLoggedIn.value) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      }
    });
  }

  Future<void> _initializeAuth() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));
      
      bool loggedIn = await checkAuthStatus();
      isLoggedIn.value = loggedIn;
    } catch (e) {
      errorMessage.value = 'Failed to initialize auth: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      // Check if a token exists
      bool authenticated = StorageService.getToken() != null;
      if (authenticated) {
        // Get user data as a JSON string and decode it
        final userJson = StorageService.getUserData();
        if (userJson != null) {
          currentUser.value = User.fromMap(jsonDecode(userJson));
        }
        isLoggedIn.value = true;
        return true;
      } else {
        isLoggedIn.value = false;
        currentUser.value = null;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Auth check failed: $e';
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.login(email, password);
      if (response != null && response['user'] != null && response['token'] != null) {
        // Corrected: Use setToken and setUserData, and await them.
        await StorageService.setToken(response['token']);
        await StorageService.setUserData(jsonEncode(response['user']));
        currentUser.value = User.fromMap(response['user']);
        isLoggedIn.value = true;
        return true;
      }
      throw Exception('Login response invalid');
    } on Exception catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      isLoggedIn.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String studentId,
    required String email,
    required String firstName,
    required String lastName,
    required String campus,
    String? program,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      if (password.length < 8) {
        throw Exception('Password must be at least 8 characters');
      }

      final userData = {
        'student_id': studentId,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'campus': campus,
        'program': program ?? '',
        'password': password,
      };

      final response = await _authService.register(userData);
      if (response != null) {
        return true;
      }
      throw Exception('Registration failed');
    } on Exception catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> logout() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.logout();
      currentUser.value = null;
      isLoggedIn.value = false;
      return true;
    } catch (e) {
      errorMessage.value = 'Logout failed: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String? getToken() {
    return StorageService.getToken();
  }

  void updateUser(User updatedUser) async {
    currentUser.value = updatedUser;
    // Corrected: Use setUserData and encode the user map.
    await StorageService.setUserData(jsonEncode(updatedUser.toMap()));
  }

  void clearErrors() {
    errorMessage.value = '';
  }

  String? getUserDisplayName() {
    final user = currentUser.value;
    if (user != null) {
      return '${user.firstName} ${user.lastName}';
    }
    return null;
  }

  String? getUserEmail() {
    return currentUser.value?.email;
  }
}
