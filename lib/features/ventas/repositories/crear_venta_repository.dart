import 'package:dio/dio.dart';

import '../../../config/api_config.dart';
import '../../../core/network/api_client.dart';

class CrearVentaRepository {
  final ApiClient _apiClient;

  CrearVentaRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<void> crearVenta({
    int? idCliente,
    required List<Map<String, int>> detalles,
  }) async {
    try {
      final Map<String, dynamic> datos = {
        'detalles': detalles,
      };

      if (idCliente != null) {
        datos['id_cliente'] = idCliente;
      }

      final response = await _apiClient.post(
        ApiConfig.ventas,
        data: datos,
      );

      _validarRespuesta(
        response.data,
        'No fue posible registrar la venta.',
      );
    } on DioException catch (e) {
      _manejarError(e, 'registrar');
    }
  }

  Future<void> actualizarVenta({
    required int idVenta,
    int? idCliente,
    required List<Map<String, int>> detalles,
  }) async {
    try {
      final Map<String, dynamic> datos = {
        'detalles': detalles,
      };

      if (idCliente != null) {
        datos['id_cliente'] = idCliente;
      }

      final response = await _apiClient.put(
        ApiConfig.ventas,
        queryParameters: {
          'id': idVenta,
        },
        data: datos,
      );

      _validarRespuesta(
        response.data,
        'No fue posible actualizar la venta.',
      );
    } on DioException catch (e) {
      _manejarError(e, 'actualizar');
    }
  }

  void _validarRespuesta(
    dynamic data,
    String mensajePredeterminado,
  ) {
    final body = Map<String, dynamic>.from(data);

    if (body['success'] != true) {
      throw Exception(
        body['message']?.toString() ?? mensajePredeterminado,
      );
    }
  }

  Never _manejarError(DioException error, String accion) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      throw Exception(data['message'].toString());
    }

    throw Exception(_mensajeError(error));
  }

  String _mensajeError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'La conexión tardó demasiado. Intenta nuevamente.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con el servidor.';
    }

    return 'Ocurrió un problema al comunicarse con el servidor.';
  }
}