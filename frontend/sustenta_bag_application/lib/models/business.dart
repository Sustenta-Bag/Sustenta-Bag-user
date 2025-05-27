class BusinessData {
  final int id;
  final String legalName;
  final String cnpj;
  final String appName;
  final String cellphone;
  final String? description;
  final bool delivery;
  final double? deliveryTax;
  final int idAddress;
  final String? logo;
  final bool status;
  final String createdAt;
  final String? updatedAt;
  final BusinessDataAddress? address;

  BusinessData({
    required this.id,
    required this.legalName,
    required this.cnpj,
    required this.appName,
    required this.cellphone,
    this.description,
    required this.delivery,
    this.deliveryTax,
    required this.idAddress,
    this.logo,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.address,
  });

  factory BusinessData.fromJson(Map<String, dynamic> json) {
    return BusinessData(
      id: json['id'],
      legalName: json['legalName'],
      cnpj: json['cnpj'],
      appName: json['appName'],
      cellphone: json['cellphone'],
      description: json['description'],
      delivery: json['delivery'] ?? false,
      deliveryTax: json['deliveryTax']?.toDouble(),
      idAddress: json['idAddress'],
      logo: json['logo'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      address: json['address'] != null
          ? BusinessDataAddress.fromJson(json['address'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'legalName': legalName,
      'cnpj': cnpj,
      'appName': appName,
      'cellphone': cellphone,
      'description': description,
      'delivery': delivery,
      'deliveryTax': deliveryTax,
      'idAddress': idAddress,
      'logo': logo,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'address': address?.toJson(),
    };
  }
}

class BusinessDataAddress {
  final int id;
  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final String? complement;

  BusinessDataAddress({
    required this.id,
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipCode,
    this.complement,
  });

  factory BusinessDataAddress.fromJson(Map<String, dynamic> json) {
    return BusinessDataAddress(
      id: json['id'],
      street: json['street'],
      number: json['number'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      complement: json['complement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'number': number,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'complement': complement,
    };
  }

  String get fullAddress {
    final baseAddress = '$street, $number, $city, $state - $zipCode';
    print('Base Address: $baseAddress');
    return complement != null ? '$baseAddress ($complement)' : baseAddress;
  }
}
