import '../../activity/data/models/activity_model.dart';
import 'models/ranking_entry.dart';

abstract class RankingUtils {
  // TODO: Reemplazar por GET /rankings cuando exista el endpoint
  static List<RankingEntry> fromActivities(
    List<ActivityModel> activities,
    String sportType,
  ) {
    final map = <String, _UserStats>{};

    for (final a in activities.where((a) => a.sportType == sportType)) {
      final key = a.userUsername.isNotEmpty ? a.userUsername : a.userName;
      final s = map[key] ?? _UserStats(name: a.userName, username: a.userUsername);
      map[key] = _UserStats(
        name: s.name,
        username: s.username,
        totalKm: s.totalKm + (a.distance ?? 0),
        count: s.count + 1,
      );
    }

    final sorted = map.values.toList()..sort((a, b) => b.totalKm.compareTo(a.totalKm));

    return sorted.take(10).toList().asMap().entries.map((e) {
      final s = e.value;
      return RankingEntry(
        position: e.key + 1,
        name: s.name,
        username: s.username,
        totalKm: s.totalKm,
        activities: s.count,
      );
    }).toList();
  }

  /// Mock de ranking para cuando no hay suficientes datos reales.
  static const mockRunners = [
    RankingEntry(position: 0, name: 'Carlos Morales', username: 'carlos_morales', totalKm: 245.3, activities: 28),
    RankingEntry(position: 0, name: 'Valentina Ruiz', username: 'vale_ruiz', totalKm: 198.7, activities: 22),
    RankingEntry(position: 0, name: 'Víctor Riquelme', username: 'victor_rq', totalKm: 167.4, activities: 19),
  ];

  static const mockCyclists = [
    RankingEntry(position: 0, name: 'Mario Sepúlveda', username: 'mario_s', totalKm: 832.0, activities: 31),
    RankingEntry(position: 0, name: 'Camila Torres', username: 'cami_tour', totalKm: 715.5, activities: 27),
    RankingEntry(position: 0, name: 'Diego Álvarez', username: 'dalvarez', totalKm: 620.2, activities: 24),
  ];

  static const mockHikers = [
    RankingEntry(position: 0, name: 'Paula Díaz', username: 'paula_trail', totalKm: 145.8, activities: 18),
    RankingEntry(position: 0, name: 'Roberto Núñez', username: 'rob_montaña', totalKm: 130.0, activities: 15),
    RankingEntry(position: 0, name: 'Ana González', username: 'anago', totalKm: 98.3, activities: 12),
  ];

  static List<RankingEntry> mockForType(String sportType) => switch (sportType) {
        'CYCLING' => mockCyclists,
        'TREKKING' => mockHikers,
        _ => mockRunners,
      };

  /// Combina datos reales con mocks para tener al menos [minEntries] entradas.
  static List<RankingEntry> combined(
    List<ActivityModel> activities,
    String sportType, {
    int minEntries = 5,
  }) {
    final real = fromActivities(activities, sportType);
    final mocks = mockForType(sportType);

    final result = [...real];
    for (final mock in mocks) {
      if (result.length >= minEntries) break;
      if (!result.any((e) => e.username == mock.username)) {
        result.add(mock);
      }
    }

    return result.take(10).toList().asMap().entries.map((e) {
      final entry = e.value;
      return RankingEntry(
        position: e.key + 1,
        name: entry.name,
        username: entry.username,
        totalKm: entry.totalKm,
        activities: entry.activities,
      );
    }).toList();
  }
}

class _UserStats {
  final String name;
  final String username;
  final double totalKm;
  final int count;

  const _UserStats({
    required this.name,
    required this.username,
    this.totalKm = 0,
    this.count = 0,
  });
}
