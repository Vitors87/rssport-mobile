import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/sport_model.dart';

abstract class SportsRepository {
  static Future<List<SportModel>> getSports() async {
    final data = await ApiClient.get(ApiEndpoints.sports);
    final list = data['sports'] as List<dynamic>;
    return list
        .map((e) => SportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
