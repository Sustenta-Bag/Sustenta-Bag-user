import 'package:sustenta_bag_application/models/review.dart';

class ReviewsResponse {
  final List<Review> reviews;
  final int total;
  final double avgRating;

  ReviewsResponse({
    required this.reviews,
    required this.total,
    required this.avgRating,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> reviewsJson = json['reviews'] as List<dynamic>;

    return ReviewsResponse(
      reviews: reviewsJson
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      avgRating: (json['avgRating'] is String)
          ? double.tryParse(json['avgRating'] as String) ?? 0.0
          : (json['avgRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
