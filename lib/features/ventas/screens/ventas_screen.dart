import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../controllers/venta_controller.dart';
import '../models/venta_model.dart';
import '../widgets/venta_card.dart';
import '../widgets/venta_metricas.dart';
import 'detalle_venta_screen.dart';
import 'crear_venta_screen.dart';
import 'dart:async';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  late final VentaController _controller;

  final TextEditingController _busquedaController =
      TextEditingController();

  Timer? _temporizadorBusqueda;

  @override
  void initState() {
    super.initState();
    _controller = VentaController();
    _controller.cargarDatos();
  }

  @override
  void dispose() {
    _temporizadorBusqueda?.cancel();
    _busquedaController.dispose();
    _controller.dispose();
    super.dispose();
  }

Future<void> _abrirDetalle(VentaModel venta) async {
  final actualizada = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => DetalleVentaScreen(
        ventaInicial: venta,
        controller: _controller,
      ),
    ),
  );
  if (!mounted) return;
  if (actualizada == true) {
    await _controller.cargarDatos();
  }
}

  // Abre el formulario para registrar una nueva venta.
  // Si se registra correctamente, actualiza el listado y las métricas.
  Future<void> _abrirCrearVenta() async {
    final registrada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CrearVentaScreen(),
      ),
    );

    if (!mounted) return;

    if (registrada == true) {
      await _controller.cargarDatos();
    }
  }

  void _programarBusqueda(String texto) {
    _temporizadorBusqueda?.cancel();

    _temporizadorBusqueda = Timer(
      const Duration(milliseconds: 350),
      () {
        if (!mounted) return;
        _controller.buscarVentas(texto);
      },
    );
  }

  Future<void> _buscar(String texto) async {
    _temporizadorBusqueda?.cancel();
    await _controller.buscarVentas(texto);
  }

  Future<void> _seleccionarEstado(String? estado) async {
    if (estado == null) return;
    await _controller.filtrarPorEstado(estado);
  }

  Future<void> _limpiarFiltros() async {
    _busquedaController.clear();
    await _controller.limpiarFiltros();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final ventas = _controller.ventas;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Ventas',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                tooltip: 'Actualizar',
                onPressed: _controller.cargarDatos,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primaryDark,
            onRefresh: _controller.cargarDatos,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Resumen de ventas',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                VentaMetricas(
                  metricas: _controller.metricas,
                  cargando: _controller.cargandoMetricas,
                  error: _controller.errorMetricas,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Últimas ventas',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _busquedaController,
                  textInputAction: TextInputAction.search,
                  onChanged: _programarBusqueda,
                  onSubmitted: _buscar,
                  decoration: InputDecoration(
                    hintText: 'Buscar por venta o cliente',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Buscar',
                      onPressed: () => _buscar(
                        _busquedaController.text,
                      ),
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _controller.estadoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Estado de la venta',
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('Todas las ventas'),
                    ),
                    DropdownMenuItem(
                      value: 'Pendiente',
                      child: Text('Pendientes'),
                    ),
                    DropdownMenuItem(
                      value: 'Pagada',
                      child: Text('Pagadas'),
                    ),
                    DropdownMenuItem(
                    value: 'Cancelada',
                    child: Text('Canceladas'),
                    ),
                  ],
                  onChanged: _seleccionarEstado,
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _limpiarFiltros,
                    icon: const Icon(Icons.filter_alt_off),
                    label: const Text('Limpiar filtros'),
                  ),
                ),

                const SizedBox(height: 8),

                if (_controller.cargandoVentas &&
                    _controller.ventas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  )
                else if (_controller.errorVentas != null &&
                    _controller.ventas.isEmpty)
                  _MensajeVentas(
                    mensaje: _controller.errorVentas!,
                    onRetry: _controller.cargarVentas,
                  )
                else if (ventas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No se encontraron ventas.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ...ventas.map(
                    (venta) => VentaCard(
                      venta: venta,
                      onTap: () => _abrirDetalle(venta),
                    ),
                  ),

                if (_controller.cargandoVentas &&
                    _controller.ventas.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Botón para registrar una nueva venta.
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _abrirCrearVenta,
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Nueva venta'),
          ),
        );
      },
    );
  }
}

class _MensajeVentas extends StatelessWidget {
  final String mensaje;
  final VoidCallback onRetry;

  const _MensajeVentas({
    required this.mensaje,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.error,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.text),
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