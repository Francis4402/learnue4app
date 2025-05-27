import 'dart:convert';

class User {
  final String? id;
  final String name;
  final String email;
  final String role;
  final String accessToken;
  final String password;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.password,
  });

  // Convert User to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  // Convert Map to User
  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return User(
      id: data['userId'] ?? data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      accessToken: data['accessToken'] ?? '',
      password: '',
    );
  }

  // Convert User to JSON string
  String fullJson() => json.encode({
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'accessToken': accessToken,
    'password': '',
  });

  factory User.fromFullJson(String source) =>
      User.fromJson(json.decode(source));
}
