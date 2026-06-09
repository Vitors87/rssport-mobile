import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/events_repository.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Future<List<EventModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = EventsRepository.getEvents();
  }

  void _retry() => setState(() => _future = EventsRepository.getEvents());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error, _retry);
          }
          final events = snapshot.data!;
          if (events.isEmpty) {
            return const Center(child: Text('No hay eventos disponibles'));
          }
          return _buildContent(events);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: const Text(
          'Crear Evento',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContent(List<EventModel> events) {
    // El evento con más participantes máximos va al banner destacado
    final featured = events.reduce(
      (a, b) => a.maxParticipants >= b.maxParticipants ? a : b,
    );
    final rest = events.where((e) => e.id != featured.id).toList();
    final sportFilters = ['Todos', ...{...events.map((e) => e.sportName)}];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFilterRow(sportFilters),
        const SizedBox(height: 16),
        _buildFeaturedBanner(featured),
        const SizedBox(height: 20),
        const Text(
          'Todos los Eventos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
        ),
        const SizedBox(height: 12),
        ...rest.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildEventRow(e),
          ),
        ),
        const SizedBox(height: 72),
      ],
    );
  }

  Widget _buildFilterRow(List<String> filters) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final isSelected = entry.key == 0;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) {},
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedBanner(EventModel event) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.black, Color(0xFF1F1F1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x4DFF6B00), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'DESTACADO',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(event.date),
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.people_rounded, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${event.maxParticipants} cupos',
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventRow(EventModel event) {
    final color = _colorForSport(event.sportType);
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
            child: Icon(Icons.flag_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatDate(event.date)} · ${event.location}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
        ],
      ),
    );
  }

  Widget _buildError(Object? error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar los eventos',
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
