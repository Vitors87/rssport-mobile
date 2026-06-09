import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      body: SingleChildScrollView(
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
            _buildEventCard(
              title: 'Maratón Ciudad 2026',
              date: '15 Jun 2026',
              location: 'Santiago, Chile',
              participants: 1240,
              category: 'Carrera',
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            _buildEventCard(
              title: 'Trail Montaña Alto',
              date: '22 Jun 2026',
              location: 'Cajón del Maipo',
              participants: 380,
              category: 'Trail',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Actividades Recientes'),
            const SizedBox(height: 12),
            _buildActivityCard(
              initials: 'CR',
              name: 'Carlos R.',
              activity: 'Carrera matutina',
              distance: '10.5 km',
              time: '52 min',
              pace: '4:57 /km',
              timeAgo: 'hace 2h',
            ),
            const SizedBox(height: 10),
            _buildActivityCard(
              initials: 'MG',
              name: 'María G.',
              activity: 'Ciclismo urbano',
              distance: '35.2 km',
              time: '1h 20min',
              pace: '26 km/h',
              timeAgo: 'hace 4h',
            ),
            const SizedBox(height: 10),
            _buildActivityCard(
              initials: 'PM',
              name: 'Pedro M.',
              activity: 'Senderismo',
              distance: '12.8 km',
              time: '3h 15min',
              pace: '15 min/km',
              timeAgo: 'hace 6h',
            ),
            const SizedBox(height: 20),
          ],
        ),
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
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
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
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.white,
              size: 28,
            ),
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
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.black,
              ),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const Text(
          'Ver todos',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String title,
    required String date,
    required String location,
    required int participants,
    required String category,
    required Color color,
  }) {
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
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.grey),
                    const SizedBox(width: 3),
                    Text(date, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_rounded, size: 11, color: AppColors.grey),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        location,
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
                  category,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$participants inscritos',
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String initials,
    required String name,
    required String activity,
    required String distance,
    required String time,
    required String pace,
    required String timeAgo,
  }) {
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
                  initials,
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
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      activity,
                      style: const TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              Text(timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(distance, 'Distancia'),
              _buildMetric(time, 'Tiempo'),
              _buildMetric(pace, 'Ritmo'),
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
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
      ],
    );
  }
}
