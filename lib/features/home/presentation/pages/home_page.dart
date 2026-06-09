import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/utils/sport_utils.dart';
import '../../../../shared/utils/app_date_utils.dart';
import '../../../activity/data/models/activity_model.dart';
import '../../../activity/data/repositories/activity_repository.dart';
import '../../../events/data/models/event_model.dart';
import '../../../events/data/repositories/events_repository.dart';
import '../../../ranking/data/models/ranking_entry.dart';
import '../../../ranking/data/ranking_utils.dart';

class _HomeData {
  final List<EventModel> events;
  final List<ActivityModel> activities;
  const _HomeData({required this.events, required this.activities});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final results = await Future.wait([
      EventsRepository.getEvents(),
      ActivityRepository.getActivities(),
    ]);
    return _HomeData(
      events: results[0] as List<EventModel>,
      activities: results[1] as List<ActivityModel>,
    );
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_run_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('RS SPORT', style: TextStyle(letterSpacing: 2, fontSize: 17)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Notificaciones disponibles próximamente'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<_HomeData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return _buildError(_retry);
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(_HomeData data) {
    final upcomingEvents = data.events.take(2).toList();
    final recentActivities = data.activities.take(3).toList();
    final top3 = RankingUtils.combined(data.activities, 'RUNNING', minEntries: 3).take(3).toList();

    // Stats reales desde actividades
    final totalKm = data.activities.fold(0.0, (s, a) => s + (a.distance ?? 0));
    final totalActivities = data.activities.length;
    final totalElevation = data.activities.fold(0.0, (s, a) => s + (a.elevation ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingCard(),
          const SizedBox(height: 20),
          _buildStatsRow(totalKm, totalActivities, totalElevation),
          const SizedBox(height: 24),
          _buildSectionHeader('Próximos Eventos', onViewAll: () => context.go(AppRoutes.events)),
          const SizedBox(height: 12),
          if (upcomingEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No hay eventos próximos', style: TextStyle(color: AppColors.grey)),
            )
          else
            ...upcomingEvents.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildEventCard(e),
              ),
            ),
          const SizedBox(height: 24),
          _buildSectionHeader('Actividades Recientes', onViewAll: () => context.go(AppRoutes.community)),
          const SizedBox(height: 12),
          if (recentActivities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No hay actividades recientes', style: TextStyle(color: AppColors.grey)),
            )
          else
            ...recentActivities.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildActivityCard(a),
              ),
            ),
          const SizedBox(height: 24),
          _buildTopRunnersSection(top3),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.black, Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, Demo Runner!',
                  style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Registra tu actividad de hoy',
                  style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.local_fire_department_rounded, color: AppColors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(double totalKm, int totalActivities, double totalElevation) {
    final kmLabel = totalKm > 0 ? '${totalKm.toStringAsFixed(1)} km' : '--';
    final elevLabel = totalElevation > 0 ? '${totalElevation.toInt()} m' : '--';

    return Row(
      children: [
        _buildStatCard(kmLabel, 'recorridos', Icons.route_rounded, AppColors.primary),
        const SizedBox(width: 10),
        _buildStatCard('$totalActivities', 'actividades', Icons.fitness_center_rounded, const Color(0xFF1565C0)),
        const SizedBox(width: 10),
        _buildStatCard(elevLabel, 'elevación', Icons.terrain_rounded, const Color(0xFF2E7D32)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.black),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'Ver todos',
            style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(EventModel event) {
    final color = SportUtils.colorForType(event.sportType);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                (color.r * 255).round(),
                (color.g * 255).round(),
                (color.b * 255).round(),
                0.12,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(SportUtils.iconForType(event.sportType), color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.black),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.grey),
                    const SizedBox(width: 3),
                    Text(AppDateUtils.format(event.date), style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_rounded, size: 11, color: AppColors.grey),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        event.location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    (color.r * 255).round(),
                    (color.g * 255).round(),
                    (color.b * 255).round(),
                    0.12,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.sportName,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${event.participants} inscritos',
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0x26FF6B00),
                child: Text(
                  activity.userInitials,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.userName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black),
                    ),
                    Text(
                      activity.title,
                      style: const TextStyle(fontSize: 12, color: AppColors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(activity.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(activity.distanceLabel, 'Distancia'),
              _buildMetric(activity.durationLabel, 'Tiempo'),
              _buildMetric(SportUtils.labelForType(activity.sportType), 'Deporte'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.black)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
      ],
    );
  }

  Widget _buildTopRunnersSection(List<RankingEntry> top3) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Corredores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
            ),
            GestureDetector(
              onTap: () => context.go(AppRoutes.ranking),
              child: const Text(
                'Ver ranking',
                style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...top3.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildRankingItem(e.value),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem(RankingEntry entry) {
    final medals = ['🥇', '🥈', '🥉'];
    final medal = entry.position <= 3 ? medals[entry.position - 1] : '#${entry.position}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0x26FF6B00),
            child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : 'U',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.black),
                ),
                Text('@${entry.username}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalKm.toStringAsFixed(1)} km',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black),
              ),
              Text('${entry.activities} act.', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el feed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black),
            ),
            const SizedBox(height: 8),
            const Text('Verifica tu conexión a internet', style: TextStyle(fontSize: 13, color: AppColors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
