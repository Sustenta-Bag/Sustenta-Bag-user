import 'package:flutter/material.dart';

class Review {
final int? id;
final int idOrder;
final int idClient;
final int rating;
final String comment;
final DateTime? createdAt;
final DateTime? updatedAt;

Review({
this.id,
required this.idOrder,
required this.idClient,
required this.rating,
required this.comment,
this.createdAt,
this.updatedAt,
});

factory Review.fromJson(Map<String, dynamic> json) {
return Review(
id: json['id'],
idOrder: json['idOrder'],
idClient: json['idClient'],
rating: json['rating'],
comment: json['comment'],
createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
);
}

Map<String, dynamic> toCreatePayload() {
return {
'idOrder': idOrder,
'idClient': idClient,
'rating': rating,
'comment': comment,
};
}
}