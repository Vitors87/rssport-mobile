# RS Sport — Comunidad Deportiva Móvil

Aplicación móvil Flutter para corredores, ciclistas, senderistas y deportistas en general.

## Stack

| Tecnología | Versión |
|---|---|
| Flutter | 3.44.1 (stable) |
| Dart | 3.12.1 |
| go_router | 14.8.1 |
| Material | 3 |
| Plataformas | Android · iOS |

## Arquitectura

Clean Architecture orientada a features:

```
lib/
├── core/           # Constantes globales
├── features/
│   ├── auth/       # Splash, Login
│   ├── home/       # Feed principal
│   ├── events/     # Eventos deportivos
│   ├── activity/   # Cronómetro y tracker
│   ├── community/  # Feed social
│   └── profile/    # Perfil de usuario
├── routing/        # app_router.dart + app_routes.dart
├── shared/         # MainScaffold (BottomNav)
└── theme/          # AppColors, AppTheme (Material 3)
```

## Colores corporativos

| Color | Hex | Uso |
|---|---|---|
| Naranja deportivo | `#FF6B00` | Primary, botones, acentos |
| Negro | `#0D0D0D` | AppBar, fondos, textos |
| Blanco | `#FFFFFF` | Superficies, textos sobre oscuro |

## Comenzar

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en emulador Android
flutter run -d emulator-5554

# Análisis estático
flutter analyze

# Tests
flutter test
```

## Estado del proyecto

- [x] Proyecto base — Clean Architecture
- [x] Tema Material 3 con colores corporativos
- [x] Navegación con go_router + ShellRoute
- [x] BottomNavigationBar (5 tabs)
- [x] Pantallas: Splash · Login · Home · Eventos · Actividad · Comunidad · Perfil
- [x] Cronómetro funcional con Timer de Dart
- [ ] Autenticación real (próxima iteración)
- [ ] GPS / geolocalización
- [ ] Integración Garmin / Strava
- [ ] Backend y base de datos
- [ ] Notificaciones Push
