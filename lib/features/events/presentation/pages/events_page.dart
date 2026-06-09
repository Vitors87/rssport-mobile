import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  static const _filters = ['Todos', 'Carrera', 'Ciclismo', 'Trail', 'Natación', 'Triatlón'];

  static const _events = [
    ('Trail Cajón del Maipo', 'Trail', '22 Jun', '380', Color(0xFF2E7D32)),
    ('Ciclovía Nocturna', 'Ciclismo', '28 Jun', '720', Color(0xFF1565C0)),
    ('5K Parque Bicentenario', 'Carrera', '30 Jun', '950', AppColors.primary),
    ('Duatlón Vitacura', 'Duatlón', '12 Jul', '210', Color(0xFF6A1B9A)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFilterRow(),
          const SizedBox(height: 16),
          _buildFeaturedBanner(),
          const SizedBox(height: 20),
          const Text(
            'Todos los Eventos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
          ),
          const SizedBox(height: 12),
          ..._events.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildEventRow(e.$1, e.$2, e.$3, e.$4, e.$5),
            ),
          ),
          const SizedBox(height: 72), // espacio para el FAB
        ],
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

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.asMap().entries.map((entry) {
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

  Widget _buildFeaturedBanner() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.black, Color(0xFF1F1F1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0x4DFF6B00), width: 1),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gran Fondo Santiago 2026',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 14),
                  SizedBox(width: 4),
                  Text('5 Jul 2026', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                  SizedBox(width: 16),
                  Icon(Icons.people_rounded, color: AppColors.primary, size: 14),
                  SizedBox(width: 4),
                  Text('2,340 inscritos', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventRow(String name, String category, String date, String participants, Color color) {
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
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black),
                ),
                const SizedBox(height: 3),
                Text(
                  '$date · $participants inscritos',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
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
              category,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
