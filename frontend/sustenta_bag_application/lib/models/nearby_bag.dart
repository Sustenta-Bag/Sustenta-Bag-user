class Business {
  final int id;
  final String name;
  final String legalName;
  final String? logo;
  final double distance;
  final BusinessAddress address;

  Business({
    required this.id,
    required this.name,
    required this.legalName,
    this.logo,
    required this.distance,
    required this.address,
  });
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      legalName: json['legalName']?.toString() ?? '',
      logo: json['logo']?.toString(),
      distance: (json['distance'] is num) ? json['distance'].toDouble() : 0.0,
      address:
          BusinessAddress.fromJson(json['address'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'legalName': legalName,
      'logo': logo,
      'distance': distance,
      'address': address.toJson(),
    };
  }
}

class BusinessAddress {
  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;

  BusinessAddress({
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipCode,
  });
  factory BusinessAddress.fromJson(Map<String, dynamic> json) {
    return BusinessAddress(
      street: json['street']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zipCode: json['zipCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'number': number,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }

  String get fullAddress {
    return '$street, $number, $city, $state - $zipCode';
  }
}

class NearbyBag {
  final int id;
  final String type;
  final double price;
  final String description;
  final String createdAt;
  final Business business;

  NearbyBag({
    required this.id,
    required this.type,
    required this.price,
    required this.description,
    required this.createdAt,
    required this.business,
  });
  factory NearbyBag.fromJson(Map<String, dynamic> json) {
    return NearbyBag(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      type: json['type']?.toString() ?? '',
      price: (json['price'] is num) ? json['price'].toDouble() : 0.0,
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      business: Business.fromJson(json['business'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'price': price,
      'description': description,
      'createdAt': createdAt,
      'business': business.toJson(),
    };
  }

  Map<String, dynamic> toBagCardFormat() {
    // Mapear tipo da API para categoria da UI
    String category = _mapTypeToCategory(type);

    return {
      'id': id.toString(),
      'imagePath': 'assets/bag.png',
      'description': description,
      'title': business.name,
      'price': price,
      'category': category,
      'business': business, // Incluir o objeto business
    };
  }

  String _mapTypeToCategory(String type) {
    switch (type.toLowerCase()) {
      case 'doce':
      case 'doces':
        return 'Doces';
      case 'salgado':
      case 'salgados':
        return 'Salgados';
      case 'mista':
      case 'mistas':
      case 'mixta':
        return 'Mistas';
      default:
        return 'Mistas';
    }
  }
}

class NearbyBagsResponse {
  final int count;
  final List<NearbyBag> data;

  NearbyBagsResponse({
    required this.count,
    required this.data,
  });

  factory NearbyBagsResponse.fromJson(Map<String, dynamic> json) {
    return NearbyBagsResponse(
      count: json['count'],
      data: (json['data'] as List)
          .map((bagJson) => NearbyBag.fromJson(bagJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'data': data.map((bag) => bag.toJson()).toList(),
    };
  }
}
