import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String accessToken;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.password,
  });

  // Convert User to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'accessToken': accessToken,
      'password': password,
    };
  }

  // Convert Map to User
  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return User(
      id: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '', // ✅ Safe fallback
      accessToken: data['accessToken'] ?? '',
      password: '', // ✅ Not returned from API
    );
  }

  // Convert User to JSON string
  String toJson() => json.encode(toMap());
}
