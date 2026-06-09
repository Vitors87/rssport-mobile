import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/utils/sport_utils.dart';
import '../../../activity/data/repositories/activity_repository.dart';
import '../../data/models/ranking_entry.dart';
import '../../data/ranking_utils.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late Future<List<_TabData>> _future;
  int _selectedTab = 0;

  static const _tabs = [
    ('Running', 'RUNNING'),
    ('Ciclismo', 'CYCLING'),
    ('Trekking', 'TREKKING'),
  ];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_TabData>> _load() async {
    final activities = await ActivityRepository.getActivities();
    return _tabs.map((t) {
      return _TabData(
        label: t.$1,
        sportType: t.$2,
        entries: RankingUtils.combined(activities, t.$2),
      );
    }).toList();
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: FutureBuilder<List<_TabData>>(
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

  Widget _buildContent(List<_TabData> tabs) {
    final current = tabs[_selectedTab];

    return Column(
      children: [
        _buildTabBar(tabs),
        Expanded(
          child: current.entries.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: current.entries.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildRankCard(current.entries[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTabBar(List<_TabData> tabs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final selected = e.key == _selectedTab;
          final color = SportUtils.colorForType(e.value.sportType);
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      SportUtils.emojiForType(e.value.sportType),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.value.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.white : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRankCard(RankingEntry entry) {
    final medals = ['🥇', '🥈', '🥉'];
    final medal = entry.position <= 3 ? medals[entry.position - 1] : null;
    final isTop3 = entry.position <= 3;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTop3 ? const Color(0x0AFF6B00) : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: isTop3
            ? Border.all(color: const Color(0x26FF6B00), width: 1)
            : null,
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 22), textAlign: TextAlign.center)
                : Text(
                    '#${entry.position}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0x26FF6B00),
            child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : 'U',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black),
                ),
                Text(
                  '@${entry.username}',
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalKm.toStringAsFixed(1)} km',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.black),
              ),
              Text(
                '${entry.activities} actividades',
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏆', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              'Aún no hay datos de ranking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Registra actividades para aparecer aquí',
              style: TextStyle(fontSize: 13, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
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
              'No se pudo cargar el ranking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black),
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
}

class _TabData {
  final String label;
  final String sportType;
  final List<RankingEntry> entries;
  const _TabData({required this.label, required this.sportType, required this.entries});
}
