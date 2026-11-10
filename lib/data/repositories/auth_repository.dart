import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/usuario_model.dart';

class AuthRepository {
  final ApiClient _api = ApiClient.instance;

  /// Iniciar sesión con correo y contraseña.
  Future<UsuarioModel> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        ApiConfig.auth,
        queryParameters: {'accion': 'login'},
        data: {'email': email.trim(), 'password': password},
      );

      final data = Map<String, dynamic>.from(response.data);

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'No fue posible iniciar sesión.');
      }

      final usuarioJson = Map<String, dynamic>.from(data['usuario']);

      final usuario = UsuarioModel.fromJson(usuarioJson);

      if (!usuario.esAdministrador) {
        await _api.clearCookies();

        throw Exception(
          'La aplicación móvil está disponible únicamente para administradores.',
        );
      }

      return usuario;
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map) {
        throw Exception(
          responseData['message']?.toString() ??
              'No fue posible conectar con el servidor.',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('El servidor tardó demasiado en responder.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'No se pudo conectar con Confypim. Comprueba tu conexión a Internet e inténtalo nuevamente.',
        );
      }

      throw Exception('Error de comunicación con el servidor.');
    }
  }

  /// Consultar si existe una sesión PHP activa.
  ///
  /// Devuelve el usuario si la sesión es válida.
  /// Devuelve null si no existe una sesión válida.
  Future<UsuarioModel?> obtenerSesionActual() async {
    try {
      final response = await _api.get(
        ApiConfig.auth,
        queryParameters: {'accion': 'session'},
      );

      final data = Map<String, dynamic>.from(response.data);

      if (data['success'] != true || data['usuario'] == null) {
        await _api.clearCookies();
        return null;
      }

      final usuarioJson = Map<String, dynamic>.from(data['usuario']);

      final usuario = UsuarioModel.fromJson(usuarioJson);

      if (!usuario.esAdministrador) {
        await _api.clearCookies();
        return null;
      }

      return usuario;
    } on DioException catch (e) {
      // HTTP 401 significa que no hay una sesión válida.
      if (e.response?.statusCode == 401) {
        await _api.clearCookies();
        return null;
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('El servidor tardó demasiado en responder.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'No se pudo conectar con Confypim. Comprueba tu conexión a Internet e inténtalo nuevamente.',
        );
      }

      final responseData = e.response?.data;

      if (responseData is Map) {
        throw Exception(
          responseData['message']?.toString() ??
              'No fue posible comprobar la sesión.',
        );
      }

      throw Exception('Error al comprobar la sesión con el servidor.');
    }
  }

  /// Cerrar sesión.
  Future<void> cerrarSesion() async {
    try {
      await _api.post(ApiConfig.auth, queryParameters: {'accion': 'logout'});
    } finally {
      // Eliminamos la cookie local al finalizar la sesión.
      await _api.clearCookies();
    }
  }
}