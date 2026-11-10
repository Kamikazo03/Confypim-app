import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../models/venta_metricas_model.dart';

class VentaMetricas extends StatelessWidget {
  final VentaMetricasModel? metricas;
  final bool cargando;
  final String? error;

  const VentaMetricas({
    super.key,
    required this.metricas,
    required this.cargando,
    this.error,
  });

  String _formatearDinero(double valor) {
    final numero = valor.round().toString();
    final resultado = numero.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '\$$resultado';
  }

  @override
  Widget build(BuildContext context) {
    if (cargando && metricas == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            color: AppColors.primaryDark,
          ),
        ),
      );
    }

    if (error != null && metricas == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          error!,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    if (metricas == null) {
      return const SizedBox.shrink();
    }

    final indicadores = [
      _IndicadorData(
        titulo: 'Ventas pagadas',
        valor: metricas!.ventasPagadas.toString(),
        icono: Icons.receipt_long_outlined,
      ),
      _IndicadorData(
        titulo: 'Ingresos totales',
        valor: _formatearDinero(metricas!.ingresosTotales),
        icono: Icons.attach_money,
      ),
      _IndicadorData(
        titulo: 'Productos vendidos',
        valor: metricas!.productosVendidos.toString(),
        icono: Icons.inventory_2_outlined,
      ),
      _IndicadorData(
        titulo: 'Productos diferentes',
        valor: metricas!.productosDiferentes.toString(),
        icono: Icons.category_outlined,
      ),
      _IndicadorData(
        titulo: 'Promedio por venta',
        valor: _formatearDinero(metricas!.promedioVenta),
        icono: Icons.trending_up,
      ),
    ];

    return Column(
      children: indicadores.map((indicador) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  indicador.icono,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  indicador.titulo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                indicador.valor,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _IndicadorData {
  final String titulo;
  final String valor;
  final IconData icono;

  const _IndicadorData({
    required this.titulo,
    required this.valor,
    required this.icono,
  });
}