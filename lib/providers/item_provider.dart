import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../config/constants.dart';

class ItemProvider extends GetxController {
  final _apiService = ApiService();
  final _authService = AuthService();

  final items = <Item>[].obs;
  final isLoading = false.obs;
  final error = Rx<String?>(null);
  final currentItem = Rx<Item?>(null);
  
  final selectedCategory = Rx<String?>(null);
  final selectedStatus = Rx<String?>(null);
  final selectedCampus = Rx<String?>(null);
  
  final categories = AppConstants.itemCategories.obs;
  final statuses = AppConstants.itemStatuses.obs;
  final campuses = AppConstants.campuses.obs;

  @override
  void onInit() {
    super.onInit();
    getItems();
  }

  /// READ - GET all items
  Future<void> getItems({
    String? type,
    String? category,
    String? status,
    String? campus,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final token = _authService.getToken();
      if (token == null) {
        error.value = 'Authentication token not found';
        return;
      }

      final fetchedItems = await _apiService.getItems(
        token,
        type: type,
      );
      
      items.value = fetchedItems;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// READ - GET single item by ID
  Future<Item?> getItemById(int itemId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final token = _authService.getToken();
      if (token == null) {
        error.value = 'Authentication token not found';
        return null;
      }

      final item = await _apiService.getItem(token, itemId);
      currentItem.value = item;
      return item;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// CREATE - Report lost item
  Future<bool> createLostItem({
    required String title,
    required String category,
    required String description,
    required String locationLost,
    required String campus,
    required DateTime dateLost,
    String? distinguishingFeatures,
    String? imagePath,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final token = _authService.getToken();
      if (token == null) {
        error.value = 'Authentication token not found';
        return false;
      }

      final formattedDate = _formatDateForBackend(dateLost);

      if (!_isValidDateFormat(formattedDate)) {
        error.value = 'Invalid date format';
        return false;
      }

      final itemData = {
        'title': title.trim(),
        'category': category.toLowerCase().trim(),
        'description': description.trim(),
        'location_lost': locationLost.trim(),
        'campus': campus.trim(),
        'date_lost': formattedDate,
        if (distinguishingFeatures != null && distinguishingFeatures.trim().isNotEmpty)
          'distinguishing_features': distinguishingFeatures.trim(),
      };

      final newItem = await _apiService.reportLostItem(
        token,
        itemData,
        imagePath,
      );
      
      items.insert(0, newItem);
      error.value = null;
      return true;
      
    } catch (e) {
      error.value = _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// CREATE - Report found item
  Future<bool> createFoundItem({
    required String title,
    required String category,
    required String description,
    required String locationFound,
    required String campus,
    required DateTime dateFound,
    String? distinguishingFeatures,
    String? imagePath,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final token = _authService.getToken();
      if (token == null) {
        error.value = 'Authentication token not found';
        return false;
      }

      final formattedDate = _formatDateForBackend(dateFound);

      if (!_isValidDateFormat(formattedDate)) {
        error.value = 'Invalid date format';
        return false;
      }

      final itemData = {
        'title': title.trim(),
        'category': category.toLowerCase().trim(),
        'description': description.trim(),
        'location_found': locationFound.trim(),
        'campus': campus.trim(),
        'date_found': formattedDate,
        if (distinguishingFeatures != null && distinguishingFeatures.trim().isNotEmpty)
          'distinguishing_features': distinguishingFeatures.trim(),
      };

      final newItem = await _apiService.reportFoundItem(
        token,
        itemData,
        imagePath,
      );
      
      items.insert(0, newItem);
      error.value = null;
      return true;
      
    } catch (e) {
      error.value = _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// UPDATE - Update item details
  Future<bool> updateItem(
    int itemId, {
    required String title,
    required String category,
    required String description,
    required String campus,
    String? status,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final token = _authService.getToken();
      if (token == null) {
        error.value = 'Authentication token not found';
        return false;
      }

      final itemData = {
        'title': title.trim(),
        'category': category.toLowerCase().trim(),
        'description': description.trim(),
        'campus': campus.trim(),
        if (status != null) 'status': status.trim(),
      };

      final updatedItem = await _apiService.updateItem(token, itemId, itemData);
      
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        items[index] = updatedItem;
      }
      currentItem.value = updatedItem;
      error.value = null;
      return true;
    } catch (e) {
      error.value = _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// UPDATE - Update item status
  Future<bool> updateItemStatus(int itemId, String newStatus) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final token = _authService.getToken();
      if (token == null) {
        error.value = 'Authentication token not found';
        return false;
      }

      final updatedItem = await _apiService.updateItemStatus(
        token,
        itemId,
        newStatus,
      );
      
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        items[index] = updatedItem;
      }
      currentItem.value = updatedItem;
      error.value = null;
      return true;
    } catch (e) {
      error.value = _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// DELETE - Delete item
  Future<bool> deleteItem(int itemId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final token = _authService.getToken();
      if (token == null) {
        error.value = 'Authentication token not found';
        return false;
      }

      await _apiService.deleteItem(token, itemId);
      items.removeWhere((item) => item.id == itemId);
      
      if (currentItem.value?.id == itemId) {
        currentItem.value = null;
      }
      error.value = null;
      return true;
    } catch (e) {
      error.value = _handleError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter items
  void setFilter({
    String? category,
    String? status,
    String? campus,
  }) {
    selectedCategory.value = category;
    selectedStatus.value = status;
    selectedCampus.value = campus;
    getItems(
      category: category,
      status: status,
      campus: campus,
    );
  }

  /// Clear filters
  void clearFilters() {
    selectedCategory.value = null;
    selectedStatus.value = null;
    selectedCampus.value = null;
    getItems();
  }

  // ==================== Helper Methods ====================

  String _formatDateForBackend(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  bool _isValidDateFormat(String date) {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return regex.hasMatch(date);
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout. Please check your internet.';
        case DioExceptionType.sendTimeout:
          return 'Request timeout. Please try again.';
        case DioExceptionType.receiveTimeout:
          return 'Response timeout. Please try again.';
        case DioExceptionType.badResponse:
          if (e.response != null) {
            final message = e.response!.data is Map
                ? e.response!.data['message'] ?? 'Unknown error'
                : 'Error: ${e.response!.statusCode}';
            return message.toString();
          }
          return 'Bad response from server';
        case DioExceptionType.cancel:
          return 'Request cancelled';
        case DioExceptionType.unknown:
          return 'Unknown error: ${e.message}';
        case DioExceptionType.badCertificate:
          return 'Certificate error';
        case DioExceptionType.connectionError:
          return 'Connection error. Please check your internet.';
      }
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}