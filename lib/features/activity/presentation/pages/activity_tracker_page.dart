import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/sports_repository.dart';

enum _ActivityState { ready, running, paused, finished }

class ActivityTrackerPage extends StatefulWidget {
  const ActivityTrackerPage({super.key});

  @override
  State<ActivityTrackerPage> createState() => _ActivityTrackerPageState();
}

class _ActivityTrackerPageState extends State<ActivityTrackerPage> {
  _ActivityState _state = _ActivityState.ready;
  Timer? _timer;
  int _elapsedSeconds = 0;

  // Deporte cargado desde la API
  String? _runningSportId;
  String _sportName = 'Running';
  bool _saving = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadRunningSport();
  }

  Future<void> _loadRunningSport() async {
    try {
      final sports = await SportsRepository.getSports();
      if (!mounted) return;
      final running = sports.where((s) => s.type == 'RUNNING').firstOrNull;
      if (running != null) {
        setState(() {
          _runningSportId = running.id;
          _sportName = running.name;
        });
      }
    } catch (_) {
      // Fallo silencioso; el botón guardar lo gestionará si sportId es null
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Formateo HH:MM:SS ─────────────────────────────────────────────────────

  String get _timeString {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  // ── Estado visual ─────────────────────────────────────────────────────────

  String get _stateLabel => switch (_state) {
        _ActivityState.ready => 'Lista',
        _ActivityState.running => 'En curso',
        _ActivityState.paused => 'Pausada',
        _ActivityState.finished => 'Finalizada',
      };

  Color get _stateColor => switch (_state) {
        _ActivityState.ready => AppColors.grey,
        _ActivityState.running => AppColors.success,
        _ActivityState.paused => AppColors.warning,
        _ActivityState.finished => AppColors.info,
      };

  // ── Acciones del cronómetro ───────────────────────────────────────────────

  void _start() {
    setState(() => _state = _ActivityState.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _state = _ActivityState.paused);
  }

  void _finish() {
    _timer?.cancel();
    setState(() => _state = _ActivityState.finished);
  }

  Future<void> _save() async {
    if (_runningSportId == null) {
      _showSnackBar('No se pudo conectar al servidor. Inténtalo de nuevo.', AppColors.error);
      return;
    }

    setState(() => _saving = true);

    try {
      await ActivityRepository.saveActivity(
        title: 'Actividad desde mobile',
        durationSeconds: _elapsedSeconds,
        sportId: _runningSportId!,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnackBar('¡Actividad guardada correctamente!', AppColors.success);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnackBar('Error al guardar. Verifica tu conexión.', AppColors.error);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actividad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildStateBadge(),
            const SizedBox(height: 36),
            _buildTimerDisplay(),
            const SizedBox(height: 36),
            _buildInfoCards(),
            const SizedBox(height: 40),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildStateBadge() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          (_stateColor.r * 255).round(),
          (_stateColor.g * 255).round(),
          (_stateColor.b * 255).round(),
          0.12,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color.fromRGBO(
            (_stateColor.r * 255).round(),
            (_stateColor.g * 255).round(),
            (_stateColor.b * 255).round(),
            0.4,
          ),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _stateColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: _stateColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            child: Text(_stateLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final shadowColor = _state == _ActivityState.running
        ? const Color(0x4DFF6B00)
        : const Color(0x33000000);

    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.black,
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 32, spreadRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _timeString,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 44,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'hh    mm    ss',
              style: TextStyle(
                color: Color(0x66FFFFFF),
                fontSize: 10,
                letterSpacing: 5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildActivityTypeCard(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Distancia',
                value: '0.00 km',
                icon: Icons.route_rounded,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Ritmo prom.',
                value: '--:-- /km',
                icon: Icons.speed_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityTypeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0x1FFF6B00),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_run_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipo de actividad',
                style: TextStyle(fontSize: 11, color: AppColors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                _sportName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.black),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.black),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return switch (_state) {
      _ActivityState.ready => _primaryButton(
          label: 'Iniciar',
          icon: Icons.play_arrow_rounded,
          onPressed: _start,
        ),
      _ActivityState.running => Row(
          children: [
            Expanded(
              child: _outlineButton(
                label: 'Pausar',
                icon: Icons.pause_rounded,
                onPressed: _pause,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dangerButton(
                label: 'Finalizar',
                icon: Icons.stop_rounded,
                onPressed: _finish,
              ),
            ),
          ],
        ),
      _ActivityState.paused => Row(
          children: [
            Expanded(
              child: _primaryButton(
                label: 'Reanudar',
                icon: Icons.play_arrow_rounded,
                onPressed: _start,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dangerButton(
                label: 'Finalizar',
                icon: Icons.stop_rounded,
                onPressed: _finish,
              ),
            ),
          ],
        ),
      _ActivityState.finished => _buildSaveSection(),
    };
  }

  Widget _buildSaveSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x0F4CAF50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x334CAF50), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actividad finalizada',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.black, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Duración total: $_timeString',
                      style: const TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: Text(_saving ? 'Guardando...' : 'Guardar actividad'),
        ),
      ],
    );
  }

  // ── Helpers de botones ────────────────────────────────────────────────────

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _outlineButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.black),
      label: Text(label, style: const TextStyle(color: AppColors.black)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.black,
        side: const BorderSide(color: AppColors.greyDark, width: 1.5),
      ),
    );
  }

  Widget _dangerButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
      ),
    );
  }
}
