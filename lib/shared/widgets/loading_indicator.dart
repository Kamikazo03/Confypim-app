import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String mensaje;

  const LoadingIndicator({super.key, this.mensaje = 'Cargando...'});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          color: AppColors.primaryDark,
          strokeWidth: 3,
        ),
        const SizedBox(height: 16),
        Text(
          mensaje,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}
