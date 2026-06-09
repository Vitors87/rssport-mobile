import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/utils/sport_utils.dart';
import '../../../../shared/utils/app_date_utils.dart';
import '../../../activity/data/models/activity_model.dart';
import '../../../activity/data/repositories/activity_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<List<ActivityModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ActivityRepository.getActivities();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _snack('Configuración disponible próximamente'),
          ),
        ],
      ),
      body: FutureBuilder<List<ActivityModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final activities = snapshot.data ?? [];
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildStats(activities),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAchievements(activities),
                      const SizedBox(height: 24),
                      _buildRecentActivities(activities.take(3).toList()),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      width: double.infinity,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0x33FF6B00),
                child: Text(
                  'DR',
                  style: TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.black, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.white, size: 15),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Demo Runner',
            style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text('@demo_runner', style: TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => _snack('Edición de perfil disponible próximamente'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              minimumSize: const Size(140, 38),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: const Text('Editar Perfil'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<ActivityModel> activities) {
    final totalKm = activities.fold(0.0, (s, a) => s + (a.distance ?? 0));
    final totalElevation = activities.fold(0.0, (s, a) => s + (a.elevation ?? 0));
    final sportTypes = activities.map((a) => a.sportType).toSet().length;

    final kmLabel = totalKm > 0 ? '${totalKm.toStringAsFixed(1)} km' : '0 km';
    final elevLabel = totalElevation > 0 ? '${totalElevation.toInt()} m' : '0 m';

    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat(kmLabel, 'recorridos'),
          _buildDivider(),
          _buildStat('${activities.length}', 'actividades'),
          _buildDivider(),
          _buildStat('$sportTypes', 'deportes'),
          _buildDivider(),
          _buildStat(elevLabel, 'elevación'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 28, color: AppColors.greyDark);

  Widget _buildAchievements(List<ActivityModel> activities) {
    final hasAny = activities.isNotEmpty;
    final hasTenK = activities.any((a) => (a.distance ?? 0) >= 10);
    final hasCycling = activities.any((a) => a.sportType == 'CYCLING');
    final hasTrekking = activities.any((a) => a.sportType == 'TREKKING');

    final badges = [
      ('🎯', 'Primer\nRegistro', hasAny),
      ('🏃', 'Primer\n10K', hasTenK),
      ('🚴', 'Ciclista', hasCycling),
      ('🥾', 'Trailero', hasTrekking),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Logros',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
        ),
        const SizedBox(height: 12),
        Row(
          children: badges
              .map(
                (b) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildBadge(b.$1, b.$2, b.$3),
                  ),
                ),
              )
              .toList(),
        ),
        if (!hasAny) ...[
          const SizedBox(height: 10),
          const Text(
            'Registra actividades para desbloquear logros',
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildBadge(String emoji, String label, bool unlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0x14FF6B00) : AppColors.greyLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked ? const Color(0x4DFF6B00) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 24,
              color: unlocked ? null : const Color(0xFFBDBDBD),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: unlocked ? AppColors.black : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(List<ActivityModel> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividades Recientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
        ),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Aún no tienes actividades registradas.',
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          )
        else
          ...activities.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildActivityRow(a),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityRow(ActivityModel activity) {
    final color = SportUtils.colorForType(activity.sportType);
    final icon = SportUtils.iconForType(activity.sportType);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                (color.r * 255).round(),
                (color.g * 255).round(),
                (color.b * 255).round(),
                0.12,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${activity.distanceLabel} · ${activity.durationLabel}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Text(
            AppDateUtils.timeAgo(activity.date),
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
