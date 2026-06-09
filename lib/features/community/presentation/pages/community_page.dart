import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/utils/sport_utils.dart';
import '../../../activity/data/models/activity_model.dart';
import '../../../activity/data/repositories/activity_repository.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late Future<List<ActivityModel>> _future;
  final Set<String> _likedIds = {};

  @override
  void initState() {
    super.initState();
    _future = ActivityRepository.getActivities();
  }

  void _retry() => setState(() => _future = ActivityRepository.getActivities());

  int _deterministicLikes(String id) {
    final sum = id.codeUnits.fold(0, (s, c) => s + c);
    return (sum % 90) + 10;
  }

  int _deterministicComments(String id) {
    final sum = id.codeUnits.fold(0, (s, c) => s + c);
    return (sum % 18) + 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              _snackBar('Búsqueda disponible próximamente'),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<ActivityModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return _buildError(_retry);
          }
          final activities = snapshot.data!;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _retry(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPublishCard(),
                const SizedBox(height: 16),
                if (activities.isEmpty)
                  _buildEmptyState()
                else
                  ...activities.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildActivityCard(a),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPublishCard() {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.activity),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0x26FF6B00),
              child: Text(
                'DR',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '¿Qué estás entrenando hoy?',
                  style: TextStyle(color: AppColors.grey, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel a) {
    final color = SportUtils.colorForType(a.sportType);
    final isLiked = _likedIds.contains(a.id);
    final baseLikes = _deterministicLikes(a.id);
    final comments = _deterministicComments(a.id);
    final totalLikes = baseLikes + (isLiked ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de deporte
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, Color.fromRGBO((color.r * 255).round(), (color.g * 255).round(), (color.b * 255).round(), 0.75)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Text(SportUtils.emojiForType(a.sportType), style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  SportUtils.labelForType(a.sportType),
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
          ),
          // Cuerpo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera usuario
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0x26FF6B00),
                      child: Text(
                        a.userInitials,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.userName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black),
                          ),
                          Text(
                            '@${a.userUsername}  ·  ${a.timeAgo}',
                            style: const TextStyle(fontSize: 11, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_horiz_rounded, color: AppColors.grey),
                  ],
                ),
                const SizedBox(height: 12),
                // Título
                Text(
                  a.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.black),
                ),
                // Descripción (si existe)
                if (a.description != null && a.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    a.description!,
                    style: const TextStyle(fontSize: 13, color: AppColors.greyDark, height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),
                // Métricas
                Row(
                  children: [
                    _buildMetricChip(Icons.route_rounded, a.distanceLabel),
                    const SizedBox(width: 8),
                    _buildMetricChip(Icons.timer_outlined, a.durationLabel),
                    if (a.elevation != null && a.elevation! > 0) ...[
                      const SizedBox(width: 8),
                      _buildMetricChip(Icons.terrain_rounded, '${a.elevation!.toInt()} m'),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                // Acciones
                Row(
                  children: [
                    _buildLikeButton(a.id, isLiked, totalLikes, color),
                    const SizedBox(width: 20),
                    _buildActionBtn(Icons.chat_bubble_outline_rounded, '$comments'),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        _snackBar('Compartir disponible próximamente'),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.share_outlined, size: 18, color: AppColors.grey),
                          SizedBox(width: 4),
                          Text('Compartir', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String value) {
    if (value == '--') return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.grey),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 12, color: AppColors.greyDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLikeButton(String id, bool isLiked, int count, Color color) {
    return GestureDetector(
      onTap: () => setState(() {
        if (isLiked) {
          _likedIds.remove(id);
        } else {
          _likedIds.add(id);
        }
      }),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isLiked),
              size: 18,
              color: isLiked ? AppColors.error : AppColors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              color: isLiked ? AppColors.error : AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text('🏃', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Aún no hay actividades.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '¡Sé el primero en registrar una actividad!',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.activity),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Registrar actividad'),
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

  SnackBar _snackBar(String message) => SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      );
}
