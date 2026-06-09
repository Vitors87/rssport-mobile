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

  /// Guarda una actividad. [durationMinutes] en minutos, consistente con el backend.
  static Future<ActivityModel> saveActivity({
    required String title,
    required String sportId,
    String? description,
    double? distance,
    int? durationMinutes,
    double? elevation,
    DateTime? date,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'sportId': sportId,
      'date': (date ?? DateTime.now()).toUtc().toIso8601String(),
    };
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (distance != null && distance > 0) body['distance'] = distance;
    if (durationMinutes != null && durationMinutes > 0) body['duration'] = durationMinutes;
    if (elevation != null && elevation > 0) body['elevation'] = elevation;

    final data = await ApiClient.post(ApiEndpoints.activities, body);
    return ActivityModel.fromJson(data['activity'] as Map<String, dynamic>);
  }
}
