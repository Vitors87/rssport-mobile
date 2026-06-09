import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/event_model.dart';

abstract class EventsRepository {
  static Future<List<EventModel>> getEvents() async {
    final data = await ApiClient.get(ApiEndpoints.events);
    final list = data['events'] as List<dynamic>;
    return list
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
