import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routing/app_routes.dart';

// Shell que envuelve las 5 secciones del BottomNavigationBar.
// GoRouter's ShellRoute pasa el widget activo como [child].
// Orden de tabs: Inicio(0) · Eventos(1) · Actividad(2) · Comunidad(3) · Perfil(4)
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.events)) return 1;
    if (location.startsWith(AppRoutes.activity)) return 2;
    if (location.startsWith(AppRoutes.community)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0; // home por defecto
  }

  void _onDestinationSelected(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.events);
      case 2:
        context.go(AppRoutes.activity);
      case 3:
        context.go(AppRoutes.community);
      case 4:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (i) => _onDestinationSelected(i, context),
        animationDuration: const Duration(milliseconds: 300),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_rounded),
            label: 'Eventos',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_button_unchecked_rounded),
            selectedIcon: Icon(Icons.directions_run_rounded),
            label: 'Actividad',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Comunidad',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
