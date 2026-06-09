import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/sport_model.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/sports_repository.dart';

class ActivityTrackerPage extends StatefulWidget {
  const ActivityTrackerPage({super.key});

  @override
  State<ActivityTrackerPage> createState() => _ActivityTrackerPageState();
}

class _ActivityTrackerPageState extends State<ActivityTrackerPage> {
  // ─── Cronómetro ────────────────────────────────────────────────────────────
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _finished = false;

  final _timerTitleCtrl = TextEditingController();
  final _timerDescCtrl = TextEditingController();
  final _timerDistCtrl = TextEditingController();
  final _timerElevCtrl = TextEditingController();
  String? _timerSportId;

  // ─── Manual ────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _manualTitleCtrl = TextEditingController();
  final _manualDescCtrl = TextEditingController();
  final _manualDistCtrl = TextEditingController();
  final _manualDurationCtrl = TextEditingController();
  final _manualElevCtrl = TextEditingController();
  String? _manualSportId;
  DateTime _manualDate = DateTime.now();

  // ─── Shared ────────────────────────────────────────────────────────────────
  List<SportModel> _sports = [];
  bool _sportsLoading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSports();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerTitleCtrl.dispose();
    _timerDescCtrl.dispose();
    _timerDistCtrl.dispose();
    _timerElevCtrl.dispose();
    _manualTitleCtrl.dispose();
    _manualDescCtrl.dispose();
    _manualDistCtrl.dispose();
    _manualDurationCtrl.dispose();
    _manualElevCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSports() async {
    setState(() => _sportsLoading = true);
    try {
      final sports = await SportsRepository.getSports();
      if (mounted) setState(() => _sports = sports);
    } catch (_) {
      // fallback silencioso; dropdown queda vacío
    } finally {
      if (mounted) setState(() => _sportsLoading = false);
    }
  }

  // ─── Timer logic ───────────────────────────────────────────────────────────
  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _finishTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _finished = true;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _finished = false;
      _elapsedSeconds = 0;
      _timerSportId = null;
    });
    _timerTitleCtrl.clear();
    _timerDescCtrl.clear();
    _timerDistCtrl.clear();
    _timerElevCtrl.clear();
  }

  String get _formattedTime {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _saveFromTimer() async {
    if (_timerTitleCtrl.text.trim().isEmpty) {
      _snack('El título es obligatorio');
      return;
    }
    if (_timerSportId == null) {
      _snack('Selecciona un deporte');
      return;
    }
    setState(() => _saving = true);
    try {
      await ActivityRepository.saveActivity(
        title: _timerTitleCtrl.text.trim(),
        sportId: _timerSportId!,
        description: _timerDescCtrl.text.trim().isEmpty ? null : _timerDescCtrl.text.trim(),
        distance: double.tryParse(_timerDistCtrl.text.trim().replaceAll(',', '.')),
        durationMinutes: (_elapsedSeconds / 60).ceil(),
        elevation: double.tryParse(_timerElevCtrl.text.trim().replaceAll(',', '.')),
      );
      if (!mounted) return;
      _snack('¡Actividad guardada con éxito!');
      _resetTimer();
    } catch (e) {
      if (!mounted) return;
      _snack('Error al guardar: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveManual() async {
    if (!_formKey.currentState!.validate()) return;
    if (_manualSportId == null) {
      _snack('Selecciona un deporte');
      return;
    }
    setState(() => _saving = true);
    try {
      await ActivityRepository.saveActivity(
        title: _manualTitleCtrl.text.trim(),
        sportId: _manualSportId!,
        description: _manualDescCtrl.text.trim().isEmpty ? null : _manualDescCtrl.text.trim(),
        distance: double.tryParse(_manualDistCtrl.text.trim().replaceAll(',', '.')),
        durationMinutes: int.tryParse(_manualDurationCtrl.text.trim()),
        elevation: double.tryParse(_manualElevCtrl.text.trim().replaceAll(',', '.')),
        date: _manualDate,
      );
      if (!mounted) return;
      _snack('¡Actividad guardada con éxito!');
      _manualTitleCtrl.clear();
      _manualDescCtrl.clear();
      _manualDistCtrl.clear();
      _manualDurationCtrl.clear();
      _manualElevCtrl.clear();
      setState(() {
        _manualSportId = null;
        _manualDate = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      _snack('Error al guardar: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _manualDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _manualDate = picked);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Actividad'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Cronómetro'), Tab(text: 'Manual')],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
          ),
        ),
        body: TabBarView(
          children: [_buildCronometroTab(), _buildManualTab()],
        ),
      ),
    );
  }

  // ─── Tab Cronómetro ────────────────────────────────────────────────────────
  Widget _buildCronometroTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTimerDisplay(),
          const SizedBox(height: 28),
          _buildTimerControls(),
          if (_finished) ...[
            const SizedBox(height: 32),
            _buildTimerSaveCard(),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final shadowColor = _isRunning ? const Color(0x4DFF6B00) : const Color(0x33000000);
    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.black,
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 36, spreadRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formattedTime,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 44,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isRunning ? 'En curso...' : (_finished ? 'Finalizada' : 'Lista'),
              style: TextStyle(
                color: _isRunning ? AppColors.primary : const Color(0xB3FFFFFF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerControls() {
    if (_finished) {
      return OutlinedButton.icon(
        onPressed: _resetTimer,
        icon: const Icon(Icons.replay_rounded),
        label: const Text('Nueva actividad'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.grey),
      );
    }
    if (!_isRunning && _elapsedSeconds == 0) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _startTimer,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Iniciar'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(_isRunning ? 'Pausar' : 'Reanudar'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _finishTimer,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('Finalizar'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSaveCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
              const SizedBox(width: 8),
              const Text(
                'Guardar actividad',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.black),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Duración total: $_formattedTime',
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          const SizedBox(height: 18),
          _buildSportDropdown(_timerSportId, (v) => setState(() => _timerSportId = v)),
          const SizedBox(height: 14),
          _buildInput(controller: _timerTitleCtrl, label: 'Título *', hint: 'Ej: Carrera matutina'),
          const SizedBox(height: 14),
          _buildInput(
            controller: _timerDescCtrl,
            label: 'Descripción (opcional)',
            hint: 'Describe tu actividad',
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  controller: _timerDistCtrl,
                  label: 'Distancia (km)',
                  hint: '0.0',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(
                  controller: _timerElevCtrl,
                  label: 'Elevación (m)',
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _saveFromTimer,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                  : const Text('Guardar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab Manual ────────────────────────────────────────────────────────────
  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registrar actividad',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.black),
            ),
            const SizedBox(height: 4),
            const Text(
              'Añade los datos de tu actividad manualmente',
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            const SizedBox(height: 22),
            _buildSportDropdown(_manualSportId, (v) => setState(() => _manualSportId = v)),
            const SizedBox(height: 14),
            TextFormField(
              controller: _manualTitleCtrl,
              decoration: _dec(label: 'Título *', hint: 'Ej: Carrera matutina'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'El título es obligatorio' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _manualDescCtrl,
              maxLines: 3,
              decoration: _dec(label: 'Descripción (opcional)', hint: 'Describe tu actividad'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _manualDistCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _dec(label: 'Distancia (km)', hint: '0.0'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _manualDurationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _dec(label: 'Duración (min)', hint: '30'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _manualElevCtrl,
              keyboardType: TextInputType.number,
              decoration: _dec(label: 'Elevación (m)', hint: '0'),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.grey),
                    const SizedBox(width: 10),
                    Text(
                      '${_manualDate.day.toString().padLeft(2, '0')}/'
                      '${_manualDate.month.toString().padLeft(2, '0')}/'
                      '${_manualDate.year}',
                      style: const TextStyle(fontSize: 14, color: AppColors.black),
                    ),
                    const Spacer(),
                    const Text(
                      'Cambiar',
                      style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _saveManual,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : const Text('Guardar actividad', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── Shared helpers ────────────────────────────────────────────────────────
  Widget _buildSportDropdown(String? value, ValueChanged<String?> onChanged) {
    if (_sportsLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Row(
          children: [
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10),
            Text('Cargando deportes…', style: TextStyle(color: AppColors.grey, fontSize: 14)),
          ],
        ),
      );
    }
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      decoration: _dec(label: 'Deporte *', hint: 'Selecciona un deporte'),
      items: _sports.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _dec(label: label, hint: hint),
    );
  }

  InputDecoration _dec({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
