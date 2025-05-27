class Address {
  final int? id;
  final String zipCode;
  final String state;
  final String city;
  final String street;
  final String number;
  final String? complement;

  Address({
    this.id,
    required this.zipCode,
    required this.state,
    required this.city,
    required this.street,
    required this.number,
    this.complement,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      zipCode: json['zipCode'],
      state: json['state'],
      city: json['city'],
      street: json['street'],
      number: json['number'],
      complement: json['complement'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zipCode': zipCode,
      'state': state,
      'city': city,
      'street': street,
      'number': number,
      'complement': complement,
    };
  }

  String get fullAddress {
    final baseAddress = '$street, $number, $city, $state - $zipCode';
    return complement != null && complement!.isNotEmpty
        ? '$baseAddress ($complement)'
        : baseAddress;
  }
}