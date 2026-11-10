import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../productos/models/producto_model.dart';
import '../controllers/crear_venta_controller.dart';

class SelectorProductos extends StatefulWidget {
  final CrearVentaController controller;

  const SelectorProductos({
    super.key,
    required this.controller,
  });

  @override
  State<SelectorProductos> createState() => _SelectorProductosState();
}

class _SelectorProductosState extends State<SelectorProductos> {
  final TextEditingController _busquedaController =
      TextEditingController();

  String _busqueda = '';

  // Productos seleccionados durante esta sesión del selector.
  final Set<int> _productosSeleccionados = {};

  @override
  void initState() {
    super.initState();

    // Recupera los productos que ya forman parte de la venta.
    _productosSeleccionados.addAll(
      widget.controller.productosSeleccionados.map(
        (item) => item.producto.idProducto,
      ),
    );
  }

  @override
  void dispose() {
    _busquedaController.dispose();
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

  void _alternarProducto(ProductoModel producto) {
    if (producto.stockDisponible <= 0) return;

    final idProducto = producto.idProducto;

    setState(() {
      if (_productosSeleccionados.contains(idProducto)) {
        _productosSeleccionados.remove(idProducto);
      } else {
        _productosSeleccionados.add(idProducto);
      }
    });
  }

  void _confirmarSeleccion() {
    final controller = widget.controller;

    final productosActuales = controller.productosSeleccionados
        .map((item) => item.producto.idProducto)
        .toSet();

    // Agrega únicamente los productos nuevos.
    final productosNuevos = _productosSeleccionados
        .difference(productosActuales);

    String? error;

    for (final idProducto in productosNuevos) {
      final producto = controller.productosDisponibles.firstWhere(
        (item) => item.idProducto == idProducto,
      );

      final agregado = controller.agregarProducto(producto);

      if (!agregado) {
        error = controller.errorFormulario ??
            'No se pudo agregar ${producto.nombre}.';
        break;
      }
    }

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error)),
        );
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Seleccionar productos',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_productosSeleccionados.length} producto(s) seleccionado(s)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _busquedaController,
                onChanged: (texto) {
                  setState(() {
                    _busqueda = texto.trim().toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar producto',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    final controller = widget.controller;

                    if (controller.cargandoProductos) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryDark,
                        ),
                      );
                    }

                    if (controller.errorProductos != null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.errorProductos!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.error,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: controller.cargarProductos,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    final productos =
                        controller.productosDisponibles.where((producto) {
                      return producto.nombre
                          .toLowerCase()
                          .contains(_busqueda);
                    }).toList();

                    if (productos.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se encontraron productos.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: productos.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 9),
                      itemBuilder: (context, index) {
                        final producto = productos[index];

                        final seleccionado = _productosSeleccionados
                            .contains(producto.idProducto);

                        return _ProductoDisponibleTile(
                          producto: producto,
                          dinero: _dinero(producto.precioUnitario),
                          seleccionado: seleccionado,
                          onTap: producto.stockDisponible > 0
                              ? () => _alternarProducto(producto)
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _confirmarSeleccion,
                  icon: const Icon(Icons.check),
                  label: Text(
                    'Agregar productos (${_productosSeleccionados.length})',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductoDisponibleTile extends StatelessWidget {
  final ProductoModel producto;
  final String dinero;
  final bool seleccionado;
  final VoidCallback? onTap;

  const _ProductoDisponibleTile({
    required this.producto,
    required this.dinero,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final agotado = producto.stockDisponible <= 0;

    return Material(
      color: seleccionado
          ? AppColors.primaryLight
          : AppColors.card,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: seleccionado
                  ? AppColors.primaryDark
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.cake_outlined,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dinero · Stock: ${producto.stockDisponible}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                agotado
                    ? Icons.block
                    : seleccionado
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                color: agotado
                    ? AppColors.textSecondary
                    : AppColors.primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}