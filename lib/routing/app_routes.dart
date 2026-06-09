abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';

  // Shell principal (BottomNavigationBar)
  // Orden: Inicio · Eventos · Actividad · Comunidad · Perfil
  static const String home = '/home';
  static const String events = '/events';
  static const String activity = '/activity';
  static const String community = '/community';
  static const String profile = '/profile';

  // Sub-rutas accesibles desde la shell (sin tab propio en el BottomNav)
  static const String ranking = '/ranking';
  // TODO: static const String eventDetail = '/events/:id';
  // TODO: static const String userDetail  = '/profile/:id';
}
