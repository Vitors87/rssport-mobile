import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

abstract class SportUtils {
  static Color colorForType(String type) => switch (type) {
        'RUNNING' => AppColors.primary,
        'CYCLING' => const Color(0xFF1565C0),
        'TREKKING' => const Color(0xFF2E7D32),
        _ => AppColors.grey,
      };

  static IconData iconForType(String type) => switch (type) {
        'RUNNING' => Icons.directions_run_rounded,
        'CYCLING' => Icons.directions_bike_rounded,
        'TREKKING' => Icons.hiking_rounded,
        _ => Icons.fitness_center_rounded,
      };

  static String emojiForType(String type) => switch (type) {
        'RUNNING' => '🏃',
        'CYCLING' => '🚴',
        'TREKKING' => '🥾',
        _ => '⚡',
      };

  static String labelForType(String type) => switch (type) {
        'RUNNING' => 'Running',
        'CYCLING' => 'Ciclismo',
        'TREKKING' => 'Trekking',
        _ => type,
      };

  /// Convierte el tipo API (RUNNING) a texto de filtro en español (Running)
  static String typeFromLabel(String label) => switch (label) {
        'Running' => 'RUNNING',
        'Ciclismo' => 'CYCLING',
        'Trekking' => 'TREKKING',
        _ => label,
      };
}
