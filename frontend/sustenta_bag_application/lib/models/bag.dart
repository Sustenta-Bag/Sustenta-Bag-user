class Bag {
  final int id;
  final String name;
  final String description;
  final double price;
  final int status;
  final int idBusiness;
  final List<String> tags;
  final String type;

  Bag({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
    required this.idBusiness,
    required this.tags,
    required this.type
  });

  factory Bag.fromJson(Map<String, dynamic> json) {
    return Bag(
      id: json['id'],
      name: json['type'],
      type: json['type']?.toString() ?? '',
      description: json['description'],
      price: json['price'].toDouble(),
      status: json['status'],
      idBusiness: json['idBusiness'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'price': price,
      'status': status,
      'idBusiness': idBusiness,
      'tags': tags,
    };
  }
}
