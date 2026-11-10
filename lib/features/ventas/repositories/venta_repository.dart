import 'package:dio/dio.dart';

import '../../../config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/venta_model.dart';
import '../models/venta_metricas_model.dart';

class VentaRepository {
  final ApiClient _api = ApiClient.instance;

  /// Consultar el listado de ventas.
  Future<List<VentaModel>> listarVentas({
    String? estado,
    String? busqueda,
  }) async {
    try {
      final parametros = <String, dynamic>{};

      if (estado != null && estado.isNotEmpty) {
        parametros['estado'] = estado;
      }

      if (busqueda != null && busqueda.trim().isNotEmpty) {
        parametros['busqueda'] = busqueda.trim();
      }

      final response = await _api.get(
        ApiConfig.ventas,
        queryParameters: parametros.isEmpty ? null : parametros,
      );

      final data = _validarRespuesta(response.data);

      if (data is! List) {
        throw Exception('El servidor devolvió un listado inválido.');
      }

      return data.map((venta) {
        return VentaModel.fromJson(
          Map<String, dynamic>.from(venta),
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception(_obtenerMensajeError(e));
    }
  }

  /// Consultar las métricas generales de ventas.
  Future<VentaMetricasModel> obtenerMetricas() async {
    try {
      final response = await _api.get(
        ApiConfig.ventas,
        queryParameters: {'accion': 'metricas'},
      );

      final data = _validarRespuesta(response.data);

      if (data is! Map) {
        throw Exception('El servidor devolvió métricas inválidas.');
      }

      return VentaMetricasModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_obtenerMensajeError(e));
    }
  }

  /// Consultar una venta con todos sus productos.
  Future<VentaModel> obtenerDetalleVenta(int idVenta) async {
    try {
      final response = await _api.get(
        ApiConfig.ventas,
        queryParameters: {'id': idVenta},
      );

      final data = _validarRespuesta(response.data);

      if (data is! Map) {
        throw Exception('El servidor devolvió un detalle inválido.');
      }

      return VentaModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_obtenerMensajeError(e));
    }
  }

  /// Marcar una venta pendiente como pagada.
  Future<void> pagarVenta(int idVenta) async {
    try {
      final response = await _api.patch(
        ApiConfig.ventas,
        queryParameters: {
          'id': idVenta,
          'accion': 'pagar',
        },
      );

      _validarAccion(response.data);
    } on DioException catch (e) {
      throw Exception(_obtenerMensajeError(e));
    }
  }

  /// Cancelar una venta pendiente.
  Future<void> cancelarVenta(int idVenta) async {
    try {
      final response = await _api.patch(
        ApiConfig.ventas,
        queryParameters: {
          'id': idVenta,
          'accion': 'cancelar',
        },
      );

      _validarAccion(response.data);
    } on DioException catch (e) {
      throw Exception(_obtenerMensajeError(e));
    }
  }

  /// Comprueba la estructura general de las consultas.
  dynamic _validarRespuesta(dynamic responseData) {
    if (responseData is! Map) {
      throw Exception('Respuesta inválida del servidor.');
    }

    final respuesta = Map<String, dynamic>.from(responseData);

    if (respuesta['success'] != true) {
      throw Exception(
        respuesta['message']?.toString() ??
            'No fue posible completar la consulta.',
      );
    }

    if (!respuesta.containsKey('data')) {
      throw Exception('La respuesta no contiene información.');
    }

    return respuesta['data'];
  }

  /// Comprueba las respuestas de las operaciones.
  void _validarAccion(dynamic responseData) {
    if (responseData is! Map) {
      throw Exception('Respuesta inválida del servidor.');
    }

    final respuesta = Map<String, dynamic>.from(responseData);

    if (respuesta['success'] != true) {
      throw Exception(
        respuesta['message']?.toString() ??
            'No fue posible completar la operación.',
      );
    }
  }

  /// Traduce los errores HTTP y de conexión.
  String _obtenerMensajeError(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      return responseData['message']?.toString() ??
          'No fue posible completar la operación.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'El servidor tardó demasiado en responder.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con Confypim. '
          'Comprueba tu conexión a Internet e inténtalo nuevamente.';
    }

    return 'Error de comunicación con el servidor.';
  }
}