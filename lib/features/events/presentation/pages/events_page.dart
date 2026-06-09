import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/utils/sport_utils.dart';
import '../../../../shared/utils/app_date_utils.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/events_repository.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Future<List<EventModel>> _future;
  String _selectedFilter = 'Todos';

  static const _filterLabels = ['Todos', 'Running', 'Ciclismo', 'Trekking'];

  // Fallback idéntico al comportamiento de la web cuando GET /events devuelve vacío
  static final List<EventModel> _fallbackEvents = [
    EventModel(
      id: 'fb-1',
      title: 'Maratón de Santiago 2026',
      description: 'La carrera más emblemática de Chile. Recorre los principales parques y avenidas de Santiago.',
      location: 'Santiago, Chile',
      date: DateTime(2026, 9, 15),
      maxParticipants: 10000,
      participants: 0,
      sportName: 'Running',
      sportType: 'RUNNING',
    ),
    EventModel(
      id: 'fb-2',
      title: 'Gran Fondo Santiago',
      description: 'Cicloturismo de larga distancia por la precordillera andina. Para ciclistas de todos los niveles.',
      location: 'Santiago, Chile',
      date: DateTime(2026, 8, 10),
      maxParticipants: 1500,
      participants: 0,
      sportName: 'Ciclismo',
      sportType: 'CYCLING',
    ),
    EventModel(
      id: 'fb-3',
      title: 'Trail Cajón del Maipo',
      description: 'Carrera de montaña con impresionantes vistas de los Andes. Distancia: 42 km.',
      location: 'Cajón del Maipo, RM',
      date: DateTime(2026, 10, 5),
      maxParticipants: 500,
      participants: 0,
      sportName: 'Trekking',
      sportType: 'TREKKING',
    ),
    EventModel(
      id: 'fb-4',
      title: '10K Parque Bicentenario',
      description: 'Carrera familiar en el corazón de Vitacura. Apta para corredores de todos los niveles.',
      location: 'Vitacura, Santiago',
      date: DateTime(2026, 7, 20),
      maxParticipants: 2000,
      participants: 0,
      sportName: 'Running',
      sportType: 'RUNNING',
    ),
    EventModel(
      id: 'fb-5',
      title: 'Trekking Volcán Villarrica',
      description: 'Expedición guiada al volcán activo más escalado del mundo. Requiere buena condición física.',
      location: 'Pucón, Araucanía',
      date: DateTime(2026, 11, 1),
      maxParticipants: 200,
      participants: 0,
      sportName: 'Trekking',
      sportType: 'TREKKING',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _future = EventsRepository.getEvents();
  }

  void _retry() => setState(() => _future = EventsRepository.getEvents());

  List<EventModel> _applyFilter(List<EventModel> events) {
    if (_selectedFilter == 'Todos') return events;
    final type = SportUtils.typeFromLabel(_selectedFilter);
    return events.where((e) => e.sportType == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Usa los filtros de deporte'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return _buildError(_retry);
          }
          // Si el API devuelve vacío, usar fallback (igual que la web)
          final allEvents = snapshot.data!.isEmpty ? _fallbackEvents : snapshot.data!;
          final filtered = _applyFilter(allEvents);
          return _buildContent(allEvents, filtered);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Crear evento disponible próximamente'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        ),
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: const Text(
          'Crear Evento',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContent(List<EventModel> all, List<EventModel> filtered) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      children: [
        // Header
        const SizedBox(height: 16),
        const Text(
          'Eventos deportivos',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          'Participa en los mejores eventos de running, ciclismo y trekking en Chile.',
          style: TextStyle(fontSize: 13, color: AppColors.grey, height: 1.4),
        ),
        const SizedBox(height: 16),
        // Filtros
        _buildFilterRow(),
        const SizedBox(height: 16),
        // Banner destacado (primer evento del filtro actual)
        if (filtered.isNotEmpty) ...[
          _buildFeaturedBanner(filtered.first),
          const SizedBox(height: 20),
        ],
        // Lista
        if (filtered.isEmpty)
          _buildEmptyFilter()
        else ...[
          Text(
            _selectedFilter == 'Todos' ? 'Todos los Eventos' : 'Eventos de $_selectedFilter',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
          ),
          const SizedBox(height: 12),
          ...filtered.skip(filtered.isEmpty ? 0 : 1).map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEventCard(e),
                ),
              ),
        ],
      ],
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterLabels.map((label) {
          final selected = _selectedFilter == label;
          final color = label == 'Todos'
              ? AppColors.primary
              : SportUtils.colorForType(SportUtils.typeFromLabel(label));
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: selected,
              selectedColor: Color.fromRGBO(
                (color.r * 255).round(),
                (color.g * 255).round(),
                (color.b * 255).round(),
                0.15,
              ),
              checkmarkColor: color,
              labelStyle: TextStyle(
                color: selected ? color : AppColors.grey,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
              side: BorderSide(color: selected ? color : AppColors.greyDark.withValues(alpha: 0.3)),
              onSelected: (_) => setState(() => _selectedFilter = label),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedBanner(EventModel event) {
    final color = SportUtils.colorForType(event.sportType);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.black, const Color(0xFF1F1F1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color.fromRGBO(
            (color.r * 255).round(),
            (color.g * 255).round(),
            (color.b * 255).round(),
            0.4,
          ),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(SportUtils.emojiForType(event.sportType), style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    const Text(
                      'DESTACADO',
                      style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            event.title,
            style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              event.description,
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 13),
              const SizedBox(width: 4),
              Text(AppDateUtils.format(event.date), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              const SizedBox(width: 14),
              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 13),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  event.location,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Inscripción disponible próximamente'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: AppColors.white,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Participaré', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final color = SportUtils.colorForType(event.sportType);
    final pct = event.maxParticipants > 0
        ? (event.participants / event.maxParticipants).clamp(0.0, 1.0)
        : 0.0;

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
                child: Icon(SportUtils.iconForType(event.sportType), color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.grey),
                        const SizedBox(width: 3),
                        Text(AppDateUtils.format(event.date), style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
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
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              event.description,
              style: const TextStyle(fontSize: 13, color: AppColors.greyDark, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          // Ubicación
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 12, color: AppColors.grey),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  event.location,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barra de participantes
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${event.participants} inscritos',
                          style: const TextStyle(fontSize: 11, color: AppColors.grey),
                        ),
                        Text(
                          'Máx. ${event.maxParticipants}',
                          style: const TextStyle(fontSize: 11, color: AppColors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.greyLight,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Botón
          OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Inscripción disponible próximamente'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color),
              minimumSize: const Size(double.infinity, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Participaré', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Text(SportUtils.emojiForType(SportUtils.typeFromLabel(_selectedFilter)), style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'No hay eventos de $_selectedFilter',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.black),
            ),
            const SizedBox(height: 8),
            const Text('Prueba con otro filtro', style: TextStyle(color: AppColors.grey, fontSize: 13)),
          ],
        ),
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
              'No se pudo cargar los eventos',
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
