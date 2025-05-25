class Bag {
  final int id;
  final String name;
  final String description;
  final double price;
  final int status;
  final int idBusiness;
  final String? imageUrl;

  Bag({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
    required this.idBusiness,
    this.imageUrl,
  });

  factory Bag.fromJson(Map<String, dynamic> json) {
    return Bag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      status: json['status'],
      idBusiness: json['idBusiness'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'status': status,
      'idBusiness': idBusiness,
      'imageUrl': imageUrl,
    };
  }
} 