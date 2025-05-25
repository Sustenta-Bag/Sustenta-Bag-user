class User {
  final int id;
  final String email;
  final String role;
  final String? firebaseId;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.firebaseId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      firebaseId: json['firebaseId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'firebaseId': firebaseId,
    };
  }
} 