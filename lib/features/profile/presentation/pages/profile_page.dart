import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildStats(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAchievements(),
                  const SizedBox(height: 20),
                  _buildRecentActivities(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
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
                  'U',
                  style: TextStyle(color: AppColors.primary, fontSize: 40, fontWeight: FontWeight.w800),
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
            'Usuario RS Sport',
            style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text('@usuario_rssport', style: TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {},
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

  Widget _buildStats() {
    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('248 km', 'totales'),
          _buildDivider(),
          _buildStat('32', 'actividades'),
          _buildDivider(),
          _buildStat('8', 'eventos'),
          _buildDivider(),
          _buildStat('154', 'seguidores'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: AppColors.white, fontSize: 19, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 28, color: AppColors.greyDark);
  }

  Widget _buildAchievements() {
    const badges = [
      ('🏃', 'Primer 10K', true),
      ('🚴', 'Ciclista', true),
      ('🏔️', 'Trailero', true),
      ('🏅', 'Maratonista', false),
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
      ],
    );
  }

  Widget _buildBadge(String emoji, String label, bool unlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
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
              fontSize: 26,
              color: unlocked ? null : const Color(0xFFBDBDBD),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: unlocked ? AppColors.black : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    const activities = [
      (Icons.directions_run_rounded, 'Carrera matutina', '10.5 km · 52 min', 'Hoy', AppColors.primary),
      (Icons.directions_bike_rounded, 'Ciclismo urbano', '35 km · 1h 20min', 'Ayer', Color(0xFF1565C0)),
      (Icons.hiking_rounded, 'Senderismo', '12.8 km · 3h 15min', 'Hace 3 días', Color(0xFF2E7D32)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividades Recientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
        ),
        const SizedBox(height: 12),
        ...activities.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildActivityRow(a.$1, a.$2, a.$3, a.$4, a.$5),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityRow(IconData icon, String name, String detail, String date, Color color) {
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
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black)),
                Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Text(date, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        ],
      ),
    );
  }
}
