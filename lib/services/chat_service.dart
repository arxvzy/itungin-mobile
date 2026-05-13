import '../core/network/dio_client.dart';

class ChatService {
  ChatService(this._client);

  final DioClient _client;

  Future<String> sendMessage(String message) async {
    try {
      final response = await _client.dio.post(
        '/chat',
        data: {'message': message},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return data['reply']?.toString() ?? data['message']?.toString() ?? '';
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }
}
