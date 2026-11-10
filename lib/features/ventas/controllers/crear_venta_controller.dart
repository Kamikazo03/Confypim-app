import 'package:flutter/material.dart';

import '../../productos/models/producto_model.dart';
import '../../productos/repositories/producto_repository.dart';
import '../models/venta_model.dart';
import '../repositories/crear_venta_repository.dart';

class ProductoVentaSeleccionado {
  final ProductoModel producto;
  final int cantidad;
  final int? cantidadOriginal;

  const ProductoVentaSeleccionado({
    required this.producto,
    required this.cantidad,
    this.cantidadOriginal,
  });

  double get subtotal => producto.precioUnitario * cantidad;

  int get stockRestanteEstimado => producto.stockDisponible - cantidad;

  ProductoVentaSeleccionado copiarConCantidad(int nuevaCantidad) {
    return ProductoVentaSeleccionado(
      producto: producto,
      cantidad: nuevaCantidad,
      cantidadOriginal: cantidadOriginal,
    );
  }
}

class CrearVentaController extends ChangeNotifier {
  final ProductoRepository _productoRepository;
  final CrearVentaRepository _ventaRepository;
  final VentaModel? ventaInicial;

  CrearVentaController({
    ProductoRepository? productoRepository,
    CrearVentaRepository? ventaRepository,
    this.ventaInicial,
  })  : _productoRepository =
            productoRepository ?? ProductoRepository(),
        _ventaRepository =
            ventaRepository ?? CrearVentaRepository();

  List<ProductoModel> productosDisponibles = [];
  List<ProductoVentaSeleccionado> productosSeleccionados = [];

  bool cargandoProductos = false;
  bool guardandoVenta = false;
  bool edicionValida = true;

  String? errorProductos;
  String? errorFormulario;

  bool get esEdicion => ventaInicial != null;

  double get totalVenta {
    return productosSeleccionados.fold(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  bool get tieneProductos => productosSeleccionados.isNotEmpty;

  Future<void> cargarProductos() async {
    cargandoProductos = true;
    errorProductos = null;
    notifyListeners();

    try {
      productosDisponibles =
          await _productoRepository.listarProductos();

      if (esEdicion) {
        _cargarProductosVentaInicial();
      }
    } catch (e) {
      errorProductos = _limpiarError(e);
    } finally {
      cargandoProductos = false;
      notifyListeners();
    }
  }

  void _cargarProductosVentaInicial() {
    productosSeleccionados.clear();
    edicionValida = true;
    errorFormulario = null;

    final venta = ventaInicial!;

    for (final detalle in venta.detalles) {
      ProductoModel? producto;

      for (final disponible in productosDisponibles) {
        if (disponible.idProducto == detalle.idProducto) {
          producto = disponible;
          break;
        }
      }

      if (producto == null) {
        edicionValida = false;
        errorFormulario =
            'No es posible editar esta venta porque uno o más '
            'productos ya no están disponibles en el catálogo. '
            'No se ha modificado la venta original.';
        continue;
      }

      productosSeleccionados.add(
        ProductoVentaSeleccionado(
          producto: producto,
          cantidad: detalle.cantidad,
          cantidadOriginal: detalle.cantidad,
        ),
      );
    }

    if (venta.detalles.isEmpty) {
      edicionValida = false;
      errorFormulario =
          'No se encontraron los productos originales de esta venta.';
    }
  }

  bool agregarProducto(ProductoModel producto) {
    errorFormulario = null;

    final indice = productosSeleccionados.indexWhere(
      (item) => item.producto.idProducto == producto.idProducto,
    );

    if (producto.stockDisponible <= 0) {
      errorFormulario =
          'Este producto no tiene existencias disponibles.';
      notifyListeners();
      return false;
    }

    if (indice != -1) {
      errorFormulario =
          'Este producto ya está agregado. Puedes modificar su cantidad.';
      notifyListeners();
      return false;
    }

    productosSeleccionados.add(
      ProductoVentaSeleccionado(
        producto: producto,
        cantidad: 1,
      ),
    );

    notifyListeners();
    return true;
  }

  bool cambiarCantidad(int idProducto, int nuevaCantidad) {
    errorFormulario = null;

    final indice = productosSeleccionados.indexWhere(
      (item) => item.producto.idProducto == idProducto,
    );

    if (indice == -1) return false;

    if (nuevaCantidad < 1) {
      errorFormulario = 'La cantidad mínima es 1.';
      notifyListeners();
      return false;
    }

    final seleccionado = productosSeleccionados[indice];
    final producto = seleccionado.producto;

    // Si la cantidad original supera el stock actual, se permite
    // conservarla o reducirla, pero no aumentarla.
    final limite = seleccionado.cantidadOriginal == null
        ? producto.stockDisponible
        : (producto.stockDisponible > seleccionado.cantidadOriginal!
            ? producto.stockDisponible
            : seleccionado.cantidadOriginal!);

    if (nuevaCantidad > limite) {
      errorFormulario =
          'La cantidad supera las existencias disponibles '
          '($limite).';
      notifyListeners();
      return false;
    }

    productosSeleccionados[indice] =
        seleccionado.copiarConCantidad(nuevaCantidad);

    notifyListeners();
    return true;
  }

  void quitarProducto(int idProducto) {
    if (productosSeleccionados.length <= 1) {
      errorFormulario =
          'La venta debe conservar al menos un producto.';
      notifyListeners();
      return;
    }

    productosSeleccionados.removeWhere(
      (item) => item.producto.idProducto == idProducto,
    );

    errorFormulario = null;
    notifyListeners();
  }

  void limpiarFormulario() {
    productosSeleccionados.clear();
    errorFormulario = null;
    notifyListeners();
  }

  Future<bool> guardarVenta({int? idCliente}) async {
    errorFormulario = null;

    if (esEdicion && !edicionValida) {
      errorFormulario =
          'No se puede actualizar la venta porque faltan '
          'productos originales en el catálogo.';
      notifyListeners();
      return false;
    }

    if (productosSeleccionados.isEmpty) {
      errorFormulario =
          'Agrega al menos un producto a la venta.';
      notifyListeners();
      return false;
    }

    guardandoVenta = true;
    notifyListeners();

    try {
      final detalles = productosSeleccionados.map((item) {
        return {
          'id_producto': item.producto.idProducto,
          'cantidad': item.cantidad,
        };
      }).toList();

      if (esEdicion) {
        await _ventaRepository.actualizarVenta(
          idVenta: ventaInicial!.idVenta,
          idCliente: idCliente ?? ventaInicial!.idCliente,
          detalles: detalles,
        );
      } else {
        await _ventaRepository.crearVenta(
          idCliente: idCliente,
          detalles: detalles,
        );
      }

      return true;
    } catch (e) {
      errorFormulario = _limpiarError(e);
      return false;
    } finally {
      guardandoVenta = false;
      notifyListeners();
    }
  }

  String _limpiarError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}