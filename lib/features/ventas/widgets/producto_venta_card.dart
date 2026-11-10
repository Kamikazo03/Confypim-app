import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/app_theme.dart';
import '../controllers/crear_venta_controller.dart';

class ProductoVentaCard extends StatefulWidget {
  final ProductoVentaSeleccionado item;
  final VoidCallback onAumentar;
  final VoidCallback onDisminuir;
  final VoidCallback onEliminar;
  final bool Function(int nuevaCantidad) onCambiarCantidad;

  const ProductoVentaCard({
    super.key,
    required this.item,
    required this.onAumentar,
    required this.onDisminuir,
    required this.onEliminar,
    required this.onCambiarCantidad,
  });

  @override
  State<ProductoVentaCard> createState() => _ProductoVentaCardState();
}

class _ProductoVentaCardState extends State<ProductoVentaCard> {
  late final TextEditingController _cantidadController;
  late final FocusNode _cantidadFocusNode;

  @override
  void initState() {
    super.initState();

    _cantidadController = TextEditingController(
      text: widget.item.cantidad.toString(),
    );

    _cantidadFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant ProductoVentaCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.cantidad != widget.item.cantidad &&
        !_cantidadFocusNode.hasFocus) {
      _actualizarTextoCantidad();
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _cantidadFocusNode.dispose();
    super.dispose();
  }

  void _actualizarTextoCantidad() {
    final texto = widget.item.cantidad.toString();

    _cantidadController.value = TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  void _confirmarCantidad(String valor) {
    final nuevaCantidad = int.tryParse(valor);

    if (nuevaCantidad == null) {
      _actualizarTextoCantidad();
      return;
    }

    widget.onCambiarCantidad(nuevaCantidad);

    _actualizarTextoCantidad();
    _cantidadFocusNode.unfocus();
  }

  String _dinero(double valor) {
    final numero = valor.round().toString();

    final resultado = numero.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return '\$$resultado';
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.item.producto;
    final stockRestante = widget.item.stockRestanteEstimado;

    final colorStock = stockRestante == 0
        ? AppColors.error
        : stockRestante <= 5
            ? AppColors.secondary
            : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Precio: ${_dinero(producto.precioUnitario)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Eliminar producto',
                onPressed: widget.onEliminar,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _filaStock(
                  'Stock disponible',
                  producto.stockDisponible.toString(),
                ),
                const SizedBox(height: 7),
                _filaStock(
                  'Cantidad en esta venta',
                  widget.item.cantidad.toString(),
                ),
                const Divider(
                  color: AppColors.border,
                  height: 18,
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Stock restante estimado',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      stockRestante.toString(),
                      style: TextStyle(
                        color: colorStock,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Estimación informativa. El inventario se actualizará '
            'cuando la venta sea pagada.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const Divider(color: AppColors.border, height: 22),
          Row(
            children: [
              const Text(
                'Cantidad',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.item.cantidad > 1
                    ? widget.onDisminuir
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primaryDark,
              ),
              SizedBox(
                width: 65,
                height: 42,
                child: TextField(
                  controller: _cantidadController,
                  focusNode: _cantidadFocusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(
                        color: AppColors.primaryDark,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: _confirmarCantidad,
                ),
              ),
              IconButton(
                onPressed: widget.item.cantidad <
                        producto.stockDisponible
                    ? widget.onAumentar
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primaryDark,
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Escribe la cantidad y pulsa Listo',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Subtotal',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _dinero(widget.item.subtotal),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filaStock(String titulo, String valor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}