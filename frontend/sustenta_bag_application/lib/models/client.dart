class Client {
  final int id;
  final String name;
  final String email;
  final String cpf;
  final String phone;
  final int idAddress;
  final int status;
  final String createdAt;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.cpf,
    required this.phone,
    required this.idAddress,
    required this.status,
    required this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      cpf: json['cpf'],
      phone: json['phone'],
      idAddress: json['idAddress'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'cpf': cpf,
      'phone': phone,
      'idAddress': idAddress,
      'status': status,
      'createdAt': createdAt,
    };
  }
} 