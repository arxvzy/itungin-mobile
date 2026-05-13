import '../core/utils/json_parsers.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.saldo,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final int saldo;
  final String? createdAt;
  final String? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: parseIntValue(json['id']),
    name: json['name']?.toString() ?? '',
    username: json['username']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    saldo: parseIntValue(json['saldo']),
    createdAt: json['created_at']?.toString(),
    updatedAt: json['updated_at']?.toString(),
  );
}

class AuthResponse {
  const AuthResponse({required this.user, required this.token});

  final UserModel user;
  final String token;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    user: json['user'] is Map
        ? UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map))
        : UserModel.fromJson(const {}),
    token: json['token']?.toString() ?? '',
  );
}
