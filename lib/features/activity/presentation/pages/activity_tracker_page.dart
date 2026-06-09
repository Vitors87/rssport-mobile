import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

// Estados posibles del cronómetro de actividad
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

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Actividad guardada correctamente'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad'),
      ),
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
          // Indicador pulsante de estado
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
    // Sombra naranja cuando está activo, negra cuando no
    final shadowColor = _state == _ActivityState.running
        ? const Color(0x4DFF6B00) // primary 30%
        : const Color(0x33000000); // negro 20%

    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.black,
          boxShadow: [
            BoxShadow(color: shadowColor, blurRadius: 32, spreadRadius: 4),
          ],
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
                color: Color(0x66FFFFFF), // blanco 40%
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
        // Selector de tipo de actividad (mock)
        _buildActivityTypeCard(),
        const SizedBox(height: 12),
        // Stats: distancia y ritmo
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
              color: const Color(0x1FFF6B00), // primary 12%
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_run_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tipo de actividad',
                style: TextStyle(fontSize: 11, color: AppColors.grey),
              ),
              SizedBox(height: 2),
              Text(
                'Running',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.black),
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
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
        // Resumen de la actividad finalizada
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x0F4CAF50), // success 6%
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
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Guardar actividad'),
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
