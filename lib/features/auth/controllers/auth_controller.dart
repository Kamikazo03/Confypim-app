import 'package:flutter/material.dart';

import '../../../data/models/usuario_model.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UsuarioModel? usuario;

  bool cargando = false;
  String? error;

  bool get autenticado => usuario != null;

  /// Restaurar una sesión existente.
  ///
  /// Devuelve true si encuentra una sesión válida.
  /// Devuelve false si no existe una sesión activa.
  Future<bool> restaurarSesion() async {
    cargando = true;
    error = null;

    notifyListeners();

    try {
      usuario = await _repository.obtenerSesionActual();

      return autenticado;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Iniciar sesión.
  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    cargando = true;
    error = null;

    notifyListeners();

    try {
      usuario = await _repository.iniciarSesion(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Cerrar sesión.
  Future<void> cerrarSesion() async {
    cargando = true;
    notifyListeners();

    try {
      await _repository.cerrarSesion();
    } catch (_) {
      // Se limpia igualmente el estado local.
    } finally {
      usuario = null;
      cargando = false;
      error = null;
      notifyListeners();
    }
  }

  /// Limpiar mensajes de error.
  void limpiarError() {
    error = null;
    notifyListeners();
  }
}
