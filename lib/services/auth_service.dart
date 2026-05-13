import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService(this._client);

  final DioClient _client;

  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await _client.dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      return AuthResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _client.dio.post(
        '/register',
        data: {
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return AuthResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _client.dio.get('/user');
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : {};
      final userJson = data['user'] ?? data['data'] ?? data;
      return UserModel.fromJson(
        userJson is Map ? Map<String, dynamic>.from(userJson) : const {},
      );
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  Future<void> logout() async {
    try {
      await _client.dio.post('/logout');
    } on ApiException {
      rethrow;
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }
}
