import '../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  DashboardService(this._client);

  final DioClient _client;

  Future<DashboardModel> getDashboard() async {
    try {
      final response = await _client.dio.get('/dashboard');
      return DashboardModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }
}
