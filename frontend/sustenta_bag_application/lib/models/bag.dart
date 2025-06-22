class Bag {
  final int id;
  final String name;
  final String description;
  final double price;
  final int status;
  final int idBusiness;
  final List<String> tags;
  final DateTime createdAt;

  Bag({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
    required this.idBusiness,
    required this.tags,
    required this.createdAt,
  });

  factory Bag.fromJson(Map<String, dynamic> json) {
    return Bag(
      id: json['id'],
      name: json['type'],
      description: json['description'],
      price: json['price'].toDouble(),
      status: json['status'],
      idBusiness: json['idBusiness'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': name,
      'description': description,
      'price': price,
      'status': status,
      'idBusiness': idBusiness,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
