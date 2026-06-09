import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/events/presentation/pages/events_page.dart';
import '../features/activity/presentation/pages/activity_tracker_page.dart';
import '../features/community/presentation/pages/community_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../shared/widgets/main_scaffold.dart';
import 'app_routes.dart';

// Configuración centralizada del router.
// ShellRoute envuelve home/events/community/profile con el MainScaffold
// (BottomNavigationBar), mientras que splash y login son rutas independientes.
abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.events,
            name: 'events',
            builder: (context, state) => const EventsPage(),
          ),
          GoRoute(
            path: AppRoutes.activity,
            name: 'activity',
            builder: (context, state) => const ActivityTrackerPage(),
          ),
          GoRoute(
            path: AppRoutes.community,
            name: 'community',
            builder: (context, state) => const CommunityPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}
