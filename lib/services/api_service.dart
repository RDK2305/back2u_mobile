import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/item.dart';
import 'storage_service.dart';

/// API Service
/// Handles all HTTP requests to the backend API using Dio
class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;

  ApiService._internal() {
    _initDio();
  }

  factory ApiService() {
    return _instance;
  }

  /// Initialize Dio HTTP client
  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.requestTimeout,
        receiveTimeout: AppConfig.requestTimeout,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token to request headers
          String? token = StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Token expired or unauthorized
            _handleUnauthorized();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Handle unauthorized access (401)
  void _handleUnauthorized() {
    StorageService.clearTokens();
    StorageService.setLoggedIn(false);
  }

  /// Get Dio instance
  Dio get dio => _dio;

  // ============ Authentication Endpoints ============

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Login failed: ${response.statusMessage}');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: userData,
      );
      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Registration failed: ${response.statusMessage}');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile(
      String token, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put(
        '/auth/profile',
        data: userData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update profile: ${response.statusMessage}');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ============ Items Endpoints ============

  /// Report a lost item with image upload
  Future<Item> reportLostItem(
    String token,
    Map<String, String> itemData,
    String? imagePath,
  ) async {
    try {
      FormData formData = FormData.fromMap(itemData);

      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(imagePath),
          ),
        );
      }

      final response = await _dio.post(
        '/items/lost',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        return Item.fromMap(data['item']);
      } else {
        throw Exception('Failed to report item');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Report a found item with image upload
  Future<Item> reportFoundItem(
    String token,
    Map<String, String> itemData,
    String? imagePath,
  ) async {
    try {
      FormData formData = FormData.fromMap(itemData);

      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(imagePath),
          ),
        );
      }

      final response = await _dio.post(
        '/items/found',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        return Item.fromMap(data['item']);
      } else {
        throw Exception('Failed to report item');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Get all items with optional filtering
  Future<List<Item>> getItems(String token, {String? type}) async {
    try {
      String url = '/items';
      if (type != null) {
        url += '?type=$type';
      }

      final response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final items = (data['data'] as List)
            .map((item) => Item.fromMap(item))
            .toList();
        return items;
      } else {
        throw Exception('Failed to get items');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Get single item by ID
  Future<Item> getItem(String token, int id) async {
    try {
      final response = await _dio.get(
        '/items/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return Item.fromMap(data['data']);
      } else {
        throw Exception('Failed to get item');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Update item
  Future<Item> updateItem(
    String token,
    int id,
    Map<String, dynamic> itemData,
  ) async {
    try {
      final response = await _dio.put(
        '/items/$id',
        data: itemData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return Item.fromMap(data['data']);
      } else {
        throw Exception('Failed to update item');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Update item status
  Future<Item> updateItemStatus(
    String token,
    int id,
    String status,
  ) async {
    try {
      final response = await _dio.put(
        '/items/$id/status',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return Item.fromMap(data['data']);
      } else {
        throw Exception('Failed to update item status');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Delete item
  Future<void> deleteItem(String token, int id) async {
    try {
      final response = await _dio.delete(
        '/items/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete item');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ============ Claims Endpoints ============

  /// Create a new claim
  Future<Map<String, dynamic>> createClaim(
    String token,
    Map<String, dynamic> claimData,
  ) async {
    try {
      final response = await _dio.post(
        '/claims',
        data: claimData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create claim');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Get claim by ID
  Future<Map<String, dynamic>> getClaim(String token, int id) async {
    try {
      final response = await _dio.get(
        '/claims/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to get claim');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Get user's claims
  Future<List<dynamic>> getMyClaims(String token) async {
    try {
      final response = await _dio.get(
        '/claims/user/my-claims',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['data'] ?? [];
      }
      throw Exception('Failed to get my claims');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Get claims for an item
  Future<List<dynamic>> getItemClaims(String token, int itemId) async {
    try {
      final response = await _dio.get(
        '/items/$itemId/claims',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['data'] ?? [];
      }
      throw Exception('Failed to get item claims');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Update claim
  Future<Map<String, dynamic>> updateClaim(
    String token,
    int id,
    Map<String, dynamic> claimData,
  ) async {
    try {
      final response = await _dio.put(
        '/claims/$id',
        data: claimData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update claim');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Verify claim
  Future<Map<String, dynamic>> verifyClaim(String token, int id) async {
    try {
      final response = await _dio.put(
        '/claims/$id/verify',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to verify claim');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Delete claim
  Future<void> deleteClaim(String token, int id) async {
    try {
      final response = await _dio.delete(
        '/claims/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete claim');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ============ Error Handling ============

  /// Get readable error message from DioException
  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return error.response?.data?['message'] ??
            'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
        return 'Network error. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
