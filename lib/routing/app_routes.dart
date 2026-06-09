// Centraliza todas las rutas de la app. Agregar nuevas rutas aquí evita
// strings mágicos dispersos en el código.
abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';

  // Shell principal (contiene el BottomNavigationBar)
  // Orden de tabs: Inicio · Eventos · Actividad · Comunidad · Perfil
  static const String home = '/home';
  static const String events = '/events';
  static const String activity = '/activity';
  static const String community = '/community';
  static const String profile = '/profile';

  // Rutas futuras (preparadas para crecimiento)
  // static const String eventDetail = '/events/:id';
  // static const String userDetail  = '/profile/:id';
  // static const String settings    = '/settings';
}
