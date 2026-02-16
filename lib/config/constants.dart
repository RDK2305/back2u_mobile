class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://back2u-h67h.onrender.com';
  static const String imageBaseUrl = 'https://back2u-h67h.onrender.com';
  
  // Timeout Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration imageTimeout = Duration(seconds: 15);
  
  // Image Placeholder
  static const String placeholderImage = 'https://via.placeholder.com/400x300?text=No+Image';
  
  // Cache Configuration
  static const int imageCacheSizeInMB = 100;
  static const int maxImageCacheAge = 7;
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Categories
  static const List<String> itemCategories = [
    'wallet',
    'phone',
    'keys',
    'id',
    'clothing',
    'bag',
    'textbook',
    'electronics',
    'other'
  ];
  
  // Campuses
  static const List<String> campuses = [
    'Main',
    'North',
    'South',
    'East',
    'West',
    'Cambridge',
    'Waterloo'
  ];
  
  // Item Statuses
  static const List<String> itemStatuses = [
    'Reported',
    'Open',
    'Claimed',
    'Returned',
    'Disposed',
    'Done',
    'Pending',
    'Verified'
  ];
  
  // Claim Statuses
  static const List<String> claimStatuses = [
    'pending',
    'verified',
    'rejected',
    'completed'
  ];
  
  // User Roles
  static const String roleStudent = 'student';
  static const String roleSecurity = 'security';
  
  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUser = 'user_data';
  static const String storageKeyRefreshToken = 'refresh_token';
}
