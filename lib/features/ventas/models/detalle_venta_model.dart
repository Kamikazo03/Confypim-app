class DetalleVentaModel {
  final int idDetalle;
  final int idVenta;
  final int idProducto;
  final String producto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const DetalleVentaModel({
    required this.idDetalle,
    required this.idVenta,
    required this.idProducto,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleVentaModel.fromJson(Map<String, dynamic> json) {
    return DetalleVentaModel(
      idDetalle: _toInt(json['id_detalle']),
      idVenta: _toInt(json['id_venta']),
      idProducto: _toInt(json['id_producto']),
      producto: json['producto']?.toString() ?? '',
      cantidad: _toInt(json['cantidad']),
      precioUnitario: _toDouble(json['precio_unitario']),
      subtotal: _toDouble(json['subtotal']),
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