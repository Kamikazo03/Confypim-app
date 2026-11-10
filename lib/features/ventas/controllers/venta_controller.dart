import 'package:flutter/material.dart';

import '../models/venta_model.dart';
import '../models/venta_metricas_model.dart';
import '../repositories/venta_repository.dart';

class VentaController extends ChangeNotifier {
  final VentaRepository _repository;

  VentaController({VentaRepository? repository})
      : _repository = repository ?? VentaRepository();

  // Información.
  List<VentaModel> ventas = [];
  VentaMetricasModel? metricas;

  // Estados de carga.
  bool cargandoVentas = false;
  bool cargandoMetricas = false;
  bool cargandoDetalle = false;
  bool procesandoAccion = false;

  // Mensajes de error.
  String? errorVentas;
  String? errorMetricas;
  String? errorDetalle;
  String? errorAccion;

  // Filtros actuales.
  String estadoSeleccionado = '';
  String busqueda = '';

  /// Cargar ventas y métricas.
  Future<void> cargarDatos() async {
    await Future.wait([
      cargarVentas(),
      cargarMetricas(),
    ]);
  }

  /// Consultar ventas aplicando los filtros actuales.
  Future<void> cargarVentas() async {
    cargandoVentas = true;
    errorVentas = null;
    notifyListeners();

    try {
      ventas = await _repository.listarVentas(
        estado: estadoSeleccionado.isEmpty
            ? null
            : estadoSeleccionado,
        busqueda: busqueda,
      );
    } catch (e) {
      errorVentas = _limpiarError(e);
    } finally {
      cargandoVentas = false;
      notifyListeners();
    }
  }

  /// Consultar indicadores de ventas.
  Future<void> cargarMetricas() async {
    cargandoMetricas = true;
    errorMetricas = null;
    notifyListeners();

    try {
      metricas = await _repository.obtenerMetricas();
    } catch (e) {
      errorMetricas = _limpiarError(e);
    } finally {
      cargandoMetricas = false;
      notifyListeners();
    }
  }

  /// Consultar el detalle de una venta específica.
  Future<VentaModel?> obtenerDetalleVenta(int idVenta) async {
    cargandoDetalle = true;
    errorDetalle = null;
    notifyListeners();

    try {
      return await _repository.obtenerDetalleVenta(idVenta);
    } catch (e) {
      errorDetalle = _limpiarError(e);
      return null;
    } finally {
      cargandoDetalle = false;
      notifyListeners();
    }
  }

  /// Pagar una venta pendiente.
  Future<bool> pagarVenta(int idVenta) async {
    if (procesandoAccion) return false;

    procesandoAccion = true;
    errorAccion = null;
    notifyListeners();

    try {
      await _repository.pagarVenta(idVenta);
      return true;
    } catch (e) {
      errorAccion = _limpiarError(e);
      return false;
    } finally {
      procesandoAccion = false;
      notifyListeners();
    }
  }

  /// Cancelar una venta pendiente.
  Future<bool> cancelarVenta(int idVenta) async {
    if (procesandoAccion) return false;

    procesandoAccion = true;
    errorAccion = null;
    notifyListeners();

    try {
      await _repository.cancelarVenta(idVenta);
      return true;
    } catch (e) {
      errorAccion = _limpiarError(e);
      return false;
    } finally {
      procesandoAccion = false;
      notifyListeners();
    }
  }

  /// Cambiar el filtro por estado.
  Future<void> filtrarPorEstado(String estado) async {
    estadoSeleccionado = estado;
    await cargarVentas();
  }

  /// Buscar ventas.
  Future<void> buscarVentas(String texto) async {
    busqueda = texto.trim();
    await cargarVentas();
  }

  /// Limpiar filtros y volver a consultar.
  Future<void> limpiarFiltros() async {
    estadoSeleccionado = '';
    busqueda = '';
    await cargarVentas();
  }

  String _limpiarError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}