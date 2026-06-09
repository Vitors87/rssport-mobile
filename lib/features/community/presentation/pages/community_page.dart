import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPublishCard(),
          const SizedBox(height: 16),
          ..._buildFeed(),
        ],
      ),
    );
  }

  Widget _buildPublishCard() {
    return Container(
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
              'T',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18),
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
          const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
        ],
      ),
    );
  }

  List<Widget> _buildFeed() {
    const posts = [
      _Post(
        user: 'Ana Martínez',
        initials: 'AM',
        timeAgo: 'hace 1h',
        emoji: '🏅',
        activityTag: '42.2 km · Carrera',
        content:
            '¡Completé mi primer maratón! 42.2 km en 4h 15min. Nunca pensé que llegaría a este momento. ¡Gracias a todos por el apoyo!',
        likes: 124,
        comments: 18,
      ),
      _Post(
        user: 'Roberto K.',
        initials: 'RK',
        timeAgo: 'hace 3h',
        emoji: '🚴',
        activityTag: '80 km · Ciclismo',
        content:
            'Salida en bicicleta de 80 km por la cordillera. Las vistas desde el alto del Maipo son increíbles. Los espero el próximo sábado.',
        likes: 87,
        comments: 12,
      ),
      _Post(
        user: 'Sofía B.',
        initials: 'SB',
        timeAgo: 'hace 5h',
        emoji: '⚡',
        activityTag: '8 km · Entrenamiento',
        content:
            'Intervalos 5×1000m. Nuevo récord personal en 1 km: 3:42. El trabajo duro siempre da frutos.',
        likes: 56,
        comments: 7,
      ),
    ];

    return posts
        .map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPostCard(p),
          ),
        )
        .toList();
  }

  Widget _buildPostCard(_Post post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del post
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0x26FF6B00),
                child: Text(
                  post.initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black),
                    ),
                    Text(post.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: AppColors.grey),
            ],
          ),
          const SizedBox(height: 12),
          // Etiqueta de actividad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x14FF6B00),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(post.emoji, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  post.activityTag,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            post.content,
            style: const TextStyle(fontSize: 14, color: AppColors.black, height: 1.5),
          ),
          const SizedBox(height: 14),
          // Acciones
          Row(
            children: [
              _buildAction(Icons.favorite_border_rounded, '${post.likes}'),
              const SizedBox(width: 20),
              _buildAction(Icons.chat_bubble_outline_rounded, '${post.comments}'),
              const Spacer(),
              _buildAction(Icons.share_outlined, 'Compartir'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _Post {
  final String user;
  final String initials;
  final String timeAgo;
  final String emoji;
  final String activityTag;
  final String content;
  final int likes;
  final int comments;

  const _Post({
    required this.user,
    required this.initials,
    required this.timeAgo,
    required this.emoji,
    required this.activityTag,
    required this.content,
    required this.likes,
    required this.comments,
  });
}
