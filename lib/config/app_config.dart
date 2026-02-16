/// Application Configuration
/// Contains API endpoints, constants, and app settings
class AppConfig {
  // API Configuration
  // For Android Emulator: 10.0.2.2 is the host machine IP
  // For physical device: Your PC/Mac IP address (e.g., 192.168.1.5:5000)
  
  static const String baseUrl = 'http://localhost:5000/api';
  // static const String baseUrl = 'http://back2u-h67h.onrender.com/api';
  // Or for Android emulator: 'http://10.0.2.2:5000/api'
  // Or for production: 'https://yourdomain.com/api'

  // API Endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String profileEndpoint = '$baseUrl/auth/profile';
  static const String itemsEndpoint = '$baseUrl/items';
  static const String claimsEndpoint = '$baseUrl/claims';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // App Defaults
  static const String appName = 'Back2U';
  static const String appVersion = '1.0.0';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int itemsPerPage = 10;

  // Image Configuration
  static const int maxImageSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];

  // Error Messages
  static const String networkErrorMessage = 'Network connection failed. Please check your internet.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unauthorizedMessage = 'Unauthorized. Please login again.';
  static const String notFoundMessage = 'Resource not found.';
}
