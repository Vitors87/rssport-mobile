abstract class AppDateUtils {
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().toUtc().difference(date.toUtc());
    if (diff.inDays >= 365) return 'hace ${diff.inDays ~/ 365}a';
    if (diff.inDays >= 30) return 'hace ${diff.inDays ~/ 30}m';
    if (diff.inDays >= 1) return 'hace ${diff.inDays}d';
    if (diff.inHours >= 1) return 'hace ${diff.inHours}h';
    if (diff.inMinutes >= 1) return 'hace ${diff.inMinutes}min';
    return 'justo ahora';
  }

  static String format(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
