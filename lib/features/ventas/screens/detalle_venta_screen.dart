import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../controllers/venta_controller.dart';
import '../models/venta_model.dart';
import 'crear_venta_screen.dart';

class DetalleVentaScreen extends StatefulWidget {
  final VentaModel ventaInicial;
  final VentaController controller;

  const DetalleVentaScreen({
    super.key,
    required this.ventaInicial,
    required this.controller,
  });

  @override
  State<DetalleVentaScreen> createState() => _DetalleVentaScreenState();
}

class _DetalleVentaScreenState extends State<DetalleVentaScreen> {
  late VentaModel _venta;

  @override
  void initState() {
    super.initState();
    _venta = widget.ventaInicial;
    _cargarDetalle();
  }

  Future<bool> _cargarDetalle() async {
    final resultado = await widget.controller.obtenerDetalleVenta(
      _venta.idVenta,
    );

    if (!mounted) return false;

    if (resultado != null) {
      setState(() {
        _venta = resultado;
      });
      return true;
    }

    return false;
  }

  String _formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  final anio = fecha.year.toString();

  return '$dia/$mes/$anio';
  }

  Future<void> _editarVenta() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CrearVentaScreen(venta: _venta),
      ),
    );

    if (resultado == true && mounted) {
      final actualizado = await _cargarDetalle();

      if (!mounted) return;

      await widget.controller.cargarDatos();

      if (!mounted) return;

      if (!actualizado) {
        Navigator.pop(context, true);
      }
    }
  }

  // =========================================================
  // CONFIRMAR PAGO
  // =========================================================

  Future<void> _confirmarPago() async {
    if (!_venta.estaPendiente ||
        widget.controller.procesandoAccion) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar pago'),
          content: Text(
            '¿Deseas registrar el pago de esta venta por '
            '${_formatearDinero(_venta.total)}?\n\n'
            'Al confirmar, se descontarán del inventario '
            'las cantidades correspondientes. '
            'Esta operación no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Volver'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar pago'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && mounted) {
      await _ejecutarPago(_venta.idVenta);
    }
  }

  Future<void> _ejecutarPago(int idVenta) async {
    final exito = await widget.controller.pagarVenta(idVenta);

    if (!mounted) return;

    if (!exito) {
      _mostrarMensaje(
        widget.controller.errorAccion ??
            'No fue posible registrar el pago.',
        esError: true,
      );
      return;
    }

    final detalleActualizado = await _cargarDetalle();

    await widget.controller.cargarDatos();

    if (!mounted) return;

    if (!detalleActualizado) {
      Navigator.pop(context, true);
      return;
    }

    _mostrarMensaje('El pago se registró correctamente.');
  }

  // =========================================================
  // CONFIRMAR CANCELACIÓN
  // =========================================================

  Future<void> _confirmarCancelacion() async {
    if (!_venta.estaPendiente ||
        widget.controller.procesandoAccion) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar venta'),
          content: const Text(
            '¿Estás seguro de que deseas cancelar esta venta?\n\n'
            'La venta quedará registrada con estado cancelado '
            'y no podrá volver a editarse ni pagarse.\n\n'
            'Como todavía está pendiente, esta acción no '
            'modificará el inventario.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Volver'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Sí, cancelar',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true && mounted) {
      await _ejecutarCancelacion(_venta.idVenta);
    }
  }

  Future<void> _ejecutarCancelacion(int idVenta) async {
    final exito = await widget.controller.cancelarVenta(idVenta);

    if (!mounted) return;

    if (!exito) {
      _mostrarMensaje(
        widget.controller.errorAccion ??
            'No fue posible cancelar la venta.',
        esError: true,
      );
      return;
    }

    final detalleActualizado = await _cargarDetalle();

    await widget.controller.cargarDatos();

    if (!mounted) return;

    if (!detalleActualizado) {
      Navigator.pop(context, true);
      return;
    }

    _mostrarMensaje('La venta fue cancelada correctamente.');
  }

  // =========================================================
  // MENSAJES Y FORMATO
  // =========================================================

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor:
            esError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatearDinero(dynamic valor) {
    final numero = valor is num
        ? valor
        : num.tryParse(valor.toString()) ?? 0;

    final entero = numero.toStringAsFixed(0);
    final buffer = StringBuffer();

    for (int i = 0; i < entero.length; i++) {
      buffer.write(entero[i]);

      final restantes = entero.length - i - 1;

      if (restantes > 0 && restantes % 3 == 0) {
        buffer.write('.');
      }
    }

    return '\$$buffer';
  }

  Color _colorEstado() {
    if (_venta.estaPagada) return AppColors.success;
    if (_venta.estaCancelada) return AppColors.error;
    return AppColors.secondary;
  }

  String _textoEstado() {
    if (_venta.estaPagada) return 'Pagada';
    if (_venta.estaCancelada) return 'Cancelada';
    return 'Pendiente';
  }

  // =========================================================
  // INTERFAZ
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final cargando = widget.controller.cargandoDetalle;
        final procesando = widget.controller.procesandoAccion;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Venta #${_venta.idVenta}'),
            backgroundColor: AppColors.background,
            actions: [
              if (_venta.estaPendiente)
                IconButton(
                  tooltip: 'Editar venta',
                  onPressed: procesando || cargando
                      ? null
                      : _editarVenta,
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          body: cargando
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: _cargarDetalle,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirInformacionGeneral(),
                        const SizedBox(height: 16),
                        _construirProductos(),
                        const SizedBox(height: 16),
                        _construirTotal(),
                        if (_venta.estaPendiente) ...[
                          const SizedBox(height: 24),
                          _construirAccionesPendientes(
                            cargando || procesando,
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _construirInformacionGeneral() {
    return _tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Información general',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _colorEstado().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _textoEstado(),
                  style: TextStyle(
                    color: _colorEstado(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _filaInformacion(
            Icons.receipt_long_outlined,
            'Número de venta',
            '#${_venta.idVenta}',
          ),
          const SizedBox(height: 12),
          _filaInformacion(
            Icons.person_outline,
            'Cliente',
            _venta.cliente,
          ),
          const SizedBox(height: 12),
          _filaInformacion(
            Icons.calendar_today_outlined,
            'Fecha',
            _formatearFecha(_venta.fechaVenta),
          ),
        ],
      ),
    );
  }

  Widget _construirProductos() {
    return _tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Productos de la venta',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          ..._venta.detalles.map((detalle) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detalle.producto,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${detalle.cantidad} x '
                          '${_formatearDinero(detalle.precioUnitario)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        _formatearDinero(detalle.subtotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _construirTotal() {
    return _tarjeta(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total de la venta',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          Text(
            _formatearDinero(_venta.total),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirAccionesPendientes(bool deshabilitado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: deshabilitado ? null : _confirmarPago,
            icon: const Icon(Icons.payment_outlined),
            label: const Text('Registrar pago'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  AppColors.success.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: deshabilitado ? null : _confirmarCancelacion,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancelar venta'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: deshabilitado ? null : _editarVenta,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar venta pendiente'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: const BorderSide(color: AppColors.secondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filaInformacion(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Row(
      children: [
        Icon(
          icono,
          color: AppColors.secondary,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tarjeta({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}