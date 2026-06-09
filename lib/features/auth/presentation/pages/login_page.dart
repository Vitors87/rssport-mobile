import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/app_routes.dart';
import '../../../../theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLogo(),
              const Spacer(flex: 2),
              _buildTagline(),
              const Spacer(flex: 3),
              _buildButtons(context),
              SizedBox(height: 28 + bottomPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.directions_run_rounded,
            color: AppColors.white,
            size: 46,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'RS SPORT',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tu comunidad deportiva',
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return const Column(
      children: [
        Text(
          'Corre más lejos.\nLlega más alto.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Únete a miles de deportistas que ya\ntransforman su entrenamiento.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Botón principal — mock: navega directo al home
        ElevatedButton(
          onPressed: () => context.go(AppRoutes.home),
          child: const Text('Comenzar ahora'),
        ),
        const SizedBox(height: 14),
        // Login Google — mock
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
          label: const Text('Continuar con Google'),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Ya tienes cuenta? ',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => context.go(AppRoutes.home),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
