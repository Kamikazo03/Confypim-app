class ProductoModel {
  final int idProducto;
  final String nombre;
  final double precioUnitario;
  final int stockDisponible;

  const ProductoModel({
    required this.idProducto,
    required this.nombre,
    required this.precioUnitario,
    required this.stockDisponible,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      idProducto: _toInt(json['id_producto']),
      nombre: json['nombre']?.toString() ?? '',
      precioUnitario: _toDouble(json['precio_unitario']),
      stockDisponible: _toInt(json['stock_disponible']),
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