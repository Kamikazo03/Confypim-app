class VentaMetricasModel {
  final int ventasPagadas;
  final double ingresosTotales;
  final int productosVendidos;
  final int productosDiferentes;
  final double promedioVenta;

  const VentaMetricasModel({
    required this.ventasPagadas,
    required this.ingresosTotales,
    required this.productosVendidos,
    required this.productosDiferentes,
    required this.promedioVenta,
  });

  factory VentaMetricasModel.fromJson(Map<String, dynamic> json) {
    return VentaMetricasModel(
      ventasPagadas: _toInt(json['ventas_pagadas']),
      ingresosTotales: _toDouble(json['ingresos_totales']),
      productosVendidos: _toInt(json['productos_vendidos']),
      productosDiferentes: _toInt(json['productos_diferentes']),
      promedioVenta: _toDouble(json['promedio_venta']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}