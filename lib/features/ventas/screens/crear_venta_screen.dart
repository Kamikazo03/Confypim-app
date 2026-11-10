import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../controllers/crear_venta_controller.dart';
import '../models/venta_model.dart';
import '../widgets/producto_venta_card.dart';
import '../widgets/selector_productos.dart';

class CrearVentaScreen extends StatefulWidget {
  final VentaModel? venta;

  const CrearVentaScreen({
    super.key,
    this.venta,
  });

  @override
  State<CrearVentaScreen> createState() => _CrearVentaScreenState();
}

class _CrearVentaScreenState extends State<CrearVentaScreen> {
  late final CrearVentaController _controller;

  bool get _esEdicion => widget.venta != null;

  @override
  void initState() {
    super.initState();

    _controller = CrearVentaController(
      ventaInicial: widget.venta,
    );

    _controller.cargarProductos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _dinero(double valor) {
    final numero = valor.round().toString();

    final resultado = numero.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return '\$$resultado';
  }

  Future<void> _abrirSelectorProductos() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (_) {
        return SelectorProductos(controller: _controller);
      },
    );
  }

  Future<void> _guardarVenta() async {
    final guardada = await _controller.guardarVenta();

    if (!mounted) return;

    if (guardada) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Venta actualizada correctamente.'
                : 'Venta registrada correctamente.',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final productos = _controller.productosSeleccionados;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _esEdicion ? 'Editar venta' : 'Crear venta',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: _controller.cargandoProductos &&
                  _controller.productosDisponibles.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryDark,
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primaryDark,
                  onRefresh: _controller.cargarProductos,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información de la venta',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  widget.venta?.cliente ??
                                      'Cliente General',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Text(
                              _esEdicion
                                  ? 'Estás modificando una venta pendiente. '
                                      'Los cambios no afectan el inventario.'
                                  : 'La venta se registrará inicialmente '
                                      'como pendiente.',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Productos de la venta',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${productos.length} agregado(s)',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_controller.errorProductos != null &&
                          _controller.productosDisponibles.isEmpty)
                        _MensajeError(
                          mensaje: _controller.errorProductos!,
                          onRetry: _controller.cargarProductos,
                        )
                      else if (productos.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppColors.border,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.shopping_basket_outlined,
                                size: 42,
                                color: AppColors.primaryDark,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Todavía no has agregado productos.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...productos.map(
                          (item) => ProductoVentaCard(
                            key: ValueKey(item.producto.idProducto),
                            item: item,
                            onAumentar: () {
                              _controller.cambiarCantidad(
                                item.producto.idProducto,
                                item.cantidad + 1,
                              );
                            },
                            onDisminuir: () {
                              _controller.cambiarCantidad(
                                item.producto.idProducto,
                                item.cantidad - 1,
                              );
                            },
                            onCambiarCantidad: (nuevaCantidad) {
                              return _controller.cambiarCantidad(
                                item.producto.idProducto,
                                nuevaCantidad,
                              );
                            },
                            onEliminar: () {
                              _controller.quitarProducto(
                                item.producto.idProducto,
                              );
                            },
                          ),
                        ),
                      if (_controller.errorFormulario != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _controller.errorFormulario!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _controller.cargandoProductos ||
                                !_controller.edicionValida
                            ? null
                            : _abrirSelectorProductos,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar producto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                          minimumSize: const Size(
                            double.infinity,
                            50,
                          ),
                          side: const BorderSide(
                            color: AppColors.primaryDark,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total de la venta',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              _dinero(_controller.totalVenta),
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _controller.guardandoVenta ||
                        _controller.cargandoProductos ||
                        productos.isEmpty ||
                        !_controller.edicionValida
                    ? null
                    : _guardarVenta,
                icon: _controller.guardandoVenta
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _controller.guardandoVenta
                      ? (_esEdicion
                          ? 'Actualizando venta...'
                          : 'Registrando venta...')
                      : (_esEdicion
                          ? 'Guardar cambios'
                          : 'Registrar venta'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MensajeError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onRetry;

  const _MensajeError({
    required this.mensaje,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}