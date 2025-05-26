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
      id: json['id'],
      name: json['name'],
      legalName: json['legalName'],
      logo: json['logo'],
      distance: json['distance'].toDouble(),
      address: BusinessAddress.fromJson(json['address']),
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
      street: json['street'],
      number: json['number'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
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
      id: json['id'],
      type: json['type'],
      price: json['price'].toDouble(),
      description: json['description'],
      createdAt: json['createdAt'],
      business: Business.fromJson(json['business']),
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

  // Método para converter para o formato esperado pelo BagCard
  Map<String, dynamic> toBagCardFormat() {
    return {
      'id': id.toString(),
      'imagePath': 'assets/bag.png',
      'description': description,
      'title': business.name,
      'price': price,
      'category': type,
    };
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
