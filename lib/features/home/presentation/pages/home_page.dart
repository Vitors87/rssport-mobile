import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../activity/data/models/activity_model.dart';
import '../../../activity/data/repositories/activity_repository.dart';
import '../../../events/data/models/event_model.dart';
import '../../../events/data/repositories/events_repository.dart';

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
            onPressed: () {},
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingCard(),
          const SizedBox(height: 20),
          _buildWeeklyStats(),
          const SizedBox(height: 24),
          _buildSectionHeader('Próximos Eventos'),
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
          _buildSectionHeader('Actividades Recientes'),
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
                  '¡Hola, Deportista!',
                  style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Llevas 7 días activo. ¡Sigue así!',
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

  Widget _buildWeeklyStats() {
    return Row(
      children: [
        _buildStatCard('42.5 km', 'esta semana', Icons.route_rounded, AppColors.primary),
        const SizedBox(width: 10),
        _buildStatCard('5', 'actividades', Icons.fitness_center_rounded, const Color(0xFF1565C0)),
        const SizedBox(width: 10),
        _buildStatCard('2.4k', 'calorías', Icons.local_fire_department_rounded, const Color(0xFFE53935)),
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

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
        ),
        const Text(
          'Ver todos',
          style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildEventCard(EventModel event) {
    final color = _colorForSport(event.sportType);
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
            child: Icon(Icons.event_rounded, color: color, size: 26),
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
                    Text(_formatDate(event.date), style: const TextStyle(fontSize: 11, color: AppColors.grey)),
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
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
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
              _buildMetric(activity.sportName, 'Deporte'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.black),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
      ],
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
            const Text(
              'Verifica tu conexión a internet',
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
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

  Color _colorForSport(String sportType) {
    return switch (sportType) {
      'RUNNING' => AppColors.primary,
      'CYCLING' => const Color(0xFF1565C0),
      'TREKKING' => const Color(0xFF2E7D32),
      _ => AppColors.grey,
    };
  }

  String _formatDate(DateTime date) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
