import 'package:back2u/config/constants.dart';

class Item {
  final int id;
  final String title;
  final String category;
  final String? description;
  final String locationFound;
  final String campus;
  final String type; // 'lost' or 'found'
  final String status;
  final String? distinguishingFeatures;
  final DateTime? dateLost;
  final DateTime? dateFound;
  final String? imageUrl;
  final int userId;

  Item({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.locationFound,
    required this.campus,
    required this.type,
    required this.status,
    this.distinguishingFeatures,
    this.dateLost,
    this.dateFound,
    this.imageUrl,
    required this.userId,
  });

  String get location => locationFound;
  DateTime? get date => dateLost ?? dateFound;
  
  /// Get the proper image URL, converting localhost to production URL if needed
  String? get displayImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    
    // If it's already a full URL with localhost, convert to production
    if (imageUrl!.contains('localhost') || imageUrl!.startsWith('http://')) {
      // Extract just the filename from localhost URL
      final uri = Uri.parse(imageUrl!);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final filename = pathSegments.last;
        return '${AppConstants.imageBaseUrl}$filename';
      }
    }
    
    // If it's already a production URL, use as-is
    if (imageUrl!.startsWith('https://')) {
      return imageUrl;
    }
    
    // Otherwise treat as relative path
    return '${AppConstants.imageBaseUrl}${imageUrl!.startsWith('/') ? '' : '/'}${imageUrl!}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'location_found': locationFound,
      'campus': campus,
      'type': type,
      'status': status,
      'distinguishing_features': distinguishingFeatures,
      'date_lost': dateLost?.toIso8601String().split('T')[0],
      'date_found': dateFound?.toIso8601String().split('T')[0],
      'image_url': imageUrl,
      'user_id': userId,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      description: map['description'],
      locationFound: map['location_found'],
      campus: map['campus'],
      type: map['type'],
      status: map['status'],
      distinguishingFeatures: map['distinguishing_features'],
      dateLost: map['date_lost'] != null ? DateTime.parse(map['date_lost']) : null,
      dateFound: map['date_found'] != null ? DateTime.parse(map['date_found']) : null,
      imageUrl: map['image_url'],
      userId: map['user_id'],
    );
  }
}
