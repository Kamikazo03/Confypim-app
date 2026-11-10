import 'detalle_venta_model.dart';

class VentaModel {
  final int idVenta;
  final int numeroVenta;
  final DateTime fechaVenta;
  final double total;
  final int idUsuario;
  final int? idCliente;
  final DateTime fechaCreacion;
  final String estado;
  final String cliente;
  final List<DetalleVentaModel> detalles;

  const VentaModel({
    required this.idVenta,
    required this.numeroVenta,
    required this.fechaVenta,
    required this.total,
    required this.idUsuario,
    this.idCliente,
    required this.fechaCreacion,
    required this.estado,
    required this.cliente,
    this.detalles = const [],
  });

  factory VentaModel.fromJson(Map<String, dynamic> json) {
    final detallesJson = json['detalles'] as List? ?? [];

    return VentaModel(
      idVenta: _toInt(json['id_venta']),
      numeroVenta: _toInt(json['numero_venta']),
      fechaVenta: DateTime.parse(json['fecha_venta'].toString()),
      total: _toDouble(json['total']),
      idUsuario: _toInt(json['id_usuario']),
      idCliente: json['id_cliente'] == null
          ? null
          : _toInt(json['id_cliente']),
      fechaCreacion: DateTime.parse(
        json['fecha_creacion'].toString(),
      ),
      estado: json['estado']?.toString() ?? '',
      cliente: json['cliente']?.toString() ?? 'Cliente General',
      detalles: detallesJson
          .map(
            (detalle) => DetalleVentaModel.fromJson(
              Map<String, dynamic>.from(detalle),
            ),
          )
          .toList(),
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

  bool get estaPendiente => estado.toLowerCase() == 'pendiente';

  bool get estaPagada => estado.toLowerCase() == 'pagada';

  bool get estaCancelada => estado.toLowerCase() == 'cancelada';
}