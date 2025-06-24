class Review {
  final int? idReview;
  final int idClient;
  final int idOrder;
  final String? clientName;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  Review({
    this.idReview,
    required this.idClient,
    required this.idOrder,
    this.clientName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      idReview: json['idReview'] as int,
      idClient: json['idClient'] as int,
      idOrder: json['idOrder'] as int,
      clientName: json['clientName'] ?? 'Cliente Anônimo',
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      "idOrder": idOrder,
      "rating": rating,
      "comment": comment,
    };
  }
}
