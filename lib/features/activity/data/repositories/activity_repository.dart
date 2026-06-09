import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/activity_model.dart';

abstract class ActivityRepository {
  static Future<List<ActivityModel>> getActivities() async {
    final data = await ApiClient.get(ApiEndpoints.activities);
    final list = data['activities'] as List<dynamic>;
    return list
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ActivityModel> saveActivity({
    required String title,
    required int durationSeconds,
    required String sportId,
  }) async {
    final data = await ApiClient.post(ApiEndpoints.activities, {
      'title': title,
      'duration': durationSeconds,
      'date': DateTime.now().toUtc().toIso8601String(),
      'sportId': sportId,
    });
    return ActivityModel.fromJson(data['activity'] as Map<String, dynamic>);
  }
}
