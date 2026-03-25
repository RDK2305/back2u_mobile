/// Rating model for the user rating/review system
class Rating {
  final int id;
  final int claimId;
  final int raterId;
  final int rateeId;
  final int rating; // 1–5
  final String? comment;
  final String? raterName;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.claimId,
    required this.raterId,
    required this.rateeId,
    required this.rating,
    this.comment,
    this.raterName,
    required this.createdAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] ?? 0,
      claimId: map['claim_id'] ?? 0,
      raterId: map['rater_id'] ?? 0,
      rateeId: map['ratee_id'] ?? 0,
      rating: map['rating'] ?? 0,
      comment: map['comment'],
      raterName: map['rater_name'] ?? map['rater_first_name'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'claim_id': claimId,
        'rater_id': raterId,
        'ratee_id': rateeId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Summary of a user's received ratings
class UserRatingSummary {
  final double averageRating;
  final int totalRatings;
  final List<Rating> ratings;

  UserRatingSummary({
    required this.averageRating,
    required this.totalRatings,
    required this.ratings,
  });

  factory UserRatingSummary.empty() =>
      UserRatingSummary(averageRating: 0, totalRatings: 0, ratings: []);

  factory UserRatingSummary.fromMap(Map<String, dynamic> map) {
    final List<dynamic> raw = map['data'] ?? map['ratings'] ?? [];
    final ratings = raw.map((r) => Rating.fromMap(r)).toList();
    // Calculate average from list
    double avg = 0;
    if (map['average'] != null) {
      avg = double.tryParse(map['average'].toString()) ?? 0;
    } else if (map['avg_rating'] != null) {
      avg = double.tryParse(map['avg_rating'].toString()) ?? 0;
    } else if (ratings.isNotEmpty) {
      avg = ratings.map((r) => r.rating).reduce((a, b) => a + b) / ratings.length;
    }
    return UserRatingSummary(
      averageRating: avg,
      totalRatings: map['total'] ?? map['total_ratings'] ?? ratings.length,
      ratings: ratings,
    );
  }
}
