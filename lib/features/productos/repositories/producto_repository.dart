import 'package:dio/dio.dart';

import '../../../config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/producto_model.dart';

class ProductoRepository {
  final ApiClient _apiClient;

  ProductoRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<List<ProductoModel>> listarProductos() async {
    try {
      final response = await _apiClient.get(ApiConfig.productos);

      final dynamic respuesta = response.data;
      dynamic data;

      // La API puede devolver directamente una lista de productos.
      if (respuesta is List) {
        data = respuesta;
      }
      // También admite el formato success/data.
      else if (respuesta is Map) {
        final body = Map<String, dynamic>.from(respuesta);

        if (body['success'] != true) {
          throw Exception(
            body['message']?.toString() ??
                'No fue posible consultar los productos.',
          );
        }

        data = body['data'];
      } else {
        throw Exception(
          'La respuesta de productos no tiene un formato válido.',
        );
      }

      if (data is! List) {
        throw Exception(
          'El servidor no devolvió una lista de productos válida.',
        );
      }

      return data.map((item) {
        if (item is! Map) {
          throw Exception(
            'Uno de los productos recibidos tiene un formato inválido.',
          );
        }

        return ProductoModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception(_mensajeError(e));
    }
  }

  String _mensajeError(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      return responseData['message']?.toString() ??
          'No fue posible consultar los productos.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'La conexión tardó demasiado. Intenta nuevamente.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con el servidor.';
    }

    return 'Ocurrió un problema al consultar los productos.';
  }
}