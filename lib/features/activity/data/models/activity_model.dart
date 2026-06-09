class ActivityModel {
  final String id;
  final String title;
  final String? description;
  final double? distance;
  final int duration;
  final double? elevation;
  final DateTime date;
  final String userName;
  final String userUsername;
  final String sportName;
  final String sportType;

  const ActivityModel({
    required this.id,
    required this.title,
    this.description,
    this.distance,
    required this.duration,
    this.elevation,
    required this.date,
    required this.userName,
    required this.userUsername,
    required this.sportName,
    required this.sportType,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final sport = json['sport'] as Map<String, dynamic>? ?? {};
    return ActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      duration: json['duration'] as int? ?? 0,
      elevation: (json['elevation'] as num?)?.toDouble(),
      date: DateTime.parse(json['date'] as String),
      userName: user['name'] as String? ?? 'Usuario',
      userUsername: user['username'] as String? ?? '',
      sportName: sport['name'] as String? ?? '',
      sportType: sport['type'] as String? ?? '',
    );
  }

  String get userInitials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (userName.isNotEmpty) return userName[0].toUpperCase();
    return 'U';
  }

  String get durationLabel {
    if (duration >= 60) {
      final h = duration ~/ 60;
      final m = duration % 60;
      return m == 0 ? '${h}h' : '${h}h ${m}min';
    }
    return '${duration}min';
  }

  String get distanceLabel {
    if (distance == null) return '--';
    return '${distance!.toStringAsFixed(1)} km';
  }

  String get timeAgo {
    final diff = DateTime.now().toUtc().difference(date.toUtc());
    if (diff.inDays >= 1) return 'hace ${diff.inDays}d';
    if (diff.inHours >= 1) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inMinutes}min';
  }
}
