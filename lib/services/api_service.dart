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

  // ============ Messages Endpoints ============

  /// Get messages for a specific claim
  Future<List<dynamic>> getClaimMessages(String token, int claimId) async {
    try {
      final response = await _dio.get(
        '/messages/claim/$claimId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return data['data'] ?? data['messages'] ?? (data is List ? data : []);
      }
      return [];
    } on DioException {
      try {
        final r2 = await _dio.get('/claims/$claimId/messages',
            options: Options(headers: {'Authorization': 'Bearer $token'}));
        if (r2.statusCode == 200) {
          final d = r2.data;
          return d['data'] ?? d['messages'] ?? (d is List ? d : []);
        }
      } catch (_) {}
      return [];
    }
  }

  /// Send a message for a claim
  Future<Map<String, dynamic>> sendClaimMessage(
    String token,
    int claimId,
    int receiverId,
    String message,
  ) async {
    try {
      final response = await _dio.post(
        '/messages',
        data: {'claim_id': claimId, 'receiver_id': receiverId, 'message': message},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {'success': true};
      }
      throw Exception('Failed to send message');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ============ Auth — Forgot Password / OTP ============

  /// Request OTP for password reset.
  /// Returns [true] when the email exists in the DB and OTP was sent.
  /// Returns [false] when the email is NOT registered (backend responds 200
  /// but without the "info" field, meaning the email was not found).
  /// Uses a 90-second timeout: Render cold-start (~50 s) + SMTP (~10 s).
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
        options: Options(
          receiveTimeout: AppConfig.emailRequestTimeout,
          sendTimeout: AppConfig.emailRequestTimeout,
        ),
      );
      // Backend sends { message, info } when email found and OTP sent.
      // When email not found it omits "info" entirely.
      final data = response.data;
      if (data is Map && data.containsKey('info')) {
        return true; // email found, OTP sent
      }
      return false; // email not registered
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Verify OTP code — returns the resetToken JWT on success, null on failure.
  /// Uses 60-second timeout to handle Render cold-start delays.
  Future<String?> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp},
        options: Options(
          receiveTimeout: AppConfig.requestTimeout,
          sendTimeout: AppConfig.requestTimeout,
        ),
      );
      if (response.statusCode == 200) {
        // Backend returns { verified: true, resetToken: "..." }
        return response.data['resetToken'] as String?;
      }
      return null;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Reset password after OTP verification.
  /// [resetToken] is the JWT returned by verifyOtp — sent as Bearer token.
  /// Body uses camelCase [newPassword] as expected by the backend.
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword, {
    String? resetToken,
  }) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
        options: Options(
          receiveTimeout: AppConfig.requestTimeout,
          sendTimeout: AppConfig.requestTimeout,
          headers: resetToken != null
              ? {'Authorization': 'Bearer $resetToken'}
              : null,
        ),
      );
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ============ Messages — Inbox ============

  /// Get user's full message inbox (all conversations grouped by claim)
  Future<List<dynamic>> getMessageInbox(String token) async {
    try {
      final response = await _dio.get(
        '/messages/inbox',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return data['data'] ?? data['messages'] ?? [];
      }
      return [];
    } on DioException {
      return [];
    }
  }

  /// Get unread message count
  Future<int> getUnreadMessageCount(String token) async {
    try {
      final response = await _dio.get(
        '/messages/unread/count',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return response.data['unread_count'] ?? 0;
      }
      return 0;
    } on DioException {
      return 0;
    }
  }

  // ============ Ratings Endpoints ============

  /// Submit a rating for a user after a claim is resolved
  Future<Map<String, dynamic>> submitRating(
    String token, {
    required int claimId,
    required int rateeId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _dio.post(
        '/ratings',
        data: {
          'claim_id': claimId,
          'ratee_id': rateeId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {'success': true};
      }
      throw Exception('Failed to submit rating');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Get ratings received by a user
  Future<Map<String, dynamic>> getUserRatings(String token, int userId) async {
    try {
      final response = await _dio.get(
        '/ratings/user/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {};
      }
      return {};
    } on DioException {
      return {};
    }
  }

  /// Get average rating for a user (public)
  Future<Map<String, dynamic>> getUserAverageRating(int userId) async {
    try {
      final response = await _dio.get('/ratings/user/$userId/average');
      if (response.statusCode == 200) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {};
      }
      return {};
    } on DioException {
      return {};
    }
  }

  /// Get ratings for a specific claim
  Future<List<dynamic>> getClaimRatings(String token, int claimId) async {
    try {
      final response = await _dio.get(
        '/ratings/claim/$claimId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return data['data'] ?? [];
      }
      return [];
    } on DioException {
      return [];
    }
  }

  // ============ Notifications Endpoints ============

  /// Get user notifications
  Future<List<dynamic>> getNotifications(String token) async {
    try {
      final response = await _dio.get(
        '/notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return data['data'] ?? data['notifications'] ?? [];
      }
      return [];
    } on DioException {
      return [];
    }
  }

  /// Mark a single notification as read
  Future<void> markNotificationRead(String token, int id) async {
    try {
      await _dio.put(
        '/notifications/$id/read',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException {
      // Ignore silently
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsRead(String token) async {
    try {
      await _dio.put(
        '/notifications/read-all',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException {
      // Ignore silently
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
        final data = error.response?.data;
        if (data is Map) {
          // Backend may return { message: "...", errors: ["...", "..."] }
          final msg = data['message'] as String? ?? '';
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            final details = errors.map((e) => '• $e').join('\n');
            return msg.isNotEmpty ? '$msg\n$details' : details;
          }
          if (msg.isNotEmpty) return msg;
        }
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
        return 'Network error. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
