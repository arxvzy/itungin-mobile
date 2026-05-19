import '../core/network/dio_client.dart';
import '../models/target_model.dart';

class TargetService {
  TargetService(this._client);

  final DioClient _client;

  Future<TargetListResponse> getTargets() async {
    try {
      final response = await _client.dio.get('/targets');
      return TargetListResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  Future<TargetModel> createTarget(CreateTargetRequest request) async {
    try {
      final response = await _client.dio.post(
        '/targets',
        data: request.toJson(),
      );
      return _modelFrom(response.data);
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  Future<TargetModel> updateTarget(int id, CreateTargetRequest request) async {
    try {
      final response = await _client.dio.put(
        '/targets/$id',
        data: request.toJson(),
      );
      return _modelFrom(response.data);
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  Future<void> deleteTarget(int id) async {
    try {
      await _client.dio.delete('/targets/$id');
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  Future<TargetModel> addFund(int id, int jumlahFund) async {
    try {
      final response = await _client.dio.post(
        '/targets/$id/add-fund',
        data: {'jumlah_fund': jumlahFund},
      );
      return _modelFrom(response.data);
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  TargetModel _modelFrom(Object? body) {
    final json = Map<String, dynamic>.from(body as Map);
    final data = json['data'] ?? json['target'] ?? json;
    return TargetModel.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
