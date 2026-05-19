import '../core/network/dio_client.dart';
import '../models/transaction_model.dart';

class TransactionService {
  TransactionService(this._client);

  final DioClient _client;

  Future<TransactionListResponse> getTransactions({
    String filter = 'semua',
  }) async {
    try {
      final response = await _client.dio.get(
        '/transactions',
        queryParameters: {'filter': filter},
      );
      return TransactionListResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  Future<TransactionModel> createTransaction(
    CreateTransactionRequest request,
  ) async {
    try {
      final response = await _client.dio.post(
        '/transactions',
        data: request.toJson(),
      );
      return _modelFrom(response.data);
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  Future<TransactionModel> updateTransaction(
    int id,
    CreateTransactionRequest request,
  ) async {
    try {
      final response = await _client.dio.put(
        '/transactions/$id',
        data: request.toJson(),
      );
      return _modelFrom(response.data);
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _client.dio.delete('/transactions/$id');
    } catch (error) {
      throw _client.normalizeError(error);
    }
  }

  TransactionModel _modelFrom(Object? body) {
    final json = Map<String, dynamic>.from(body as Map);
    final data = json['data'] ?? json['transaction'] ?? json;
    return TransactionModel.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
