class Review {
  final String? id;
  final String? userName;
  final DateTime? date;
  final int idOrder;
  final int rating;
  final String comment;
  final int idClient;

  Review({
    this.id,
    this.userName,
    this.date,
    required this.idOrder,
    required this.rating,
    required this.comment,
    required this.idClient,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['idReview']?.toString(),
      userName: 'Cliente ID: ${json['idClient']?.toString() ?? 'Desconhecido'}',
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] ?? '',
      date: DateTime.tryParse(json['createdAt'] ?? ''),
      idClient: json['idClient'] as int,
      idOrder: json['idOrder'] as int,
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
