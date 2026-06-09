class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final int maxParticipants;
  final int participants;
  final String sportName;
  final String sportType;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.maxParticipants,
    required this.participants,
    required this.sportName,
    required this.sportType,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final sport = json['sport'] as Map<String, dynamic>? ?? {};
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      maxParticipants: json['maxParticipants'] as int? ?? 0,
      participants: json['participants'] as int? ?? 0,
      sportName: sport['name'] as String? ?? '',
      sportType: sport['type'] as String? ?? '',
    );
  }
}
