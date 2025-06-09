import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../SQLite/database_helper.dart';
import '../Components/footer_nav.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({Key? key}) : super(key: key);

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  String? nombreCliente;
  int numeroComprado = 0;
  double? precioComprado;

  final List<double> precios =
  List.generate(20, (i) => (i + 1) * 0.25); // 0.25 a 5.00

  /// Notificación superior
  void _showTopNotification(String message) {
    final overlay = Overlay.of(context)!;
    final entry = OverlayEntry(
      builder: (ctx) {
        final topPadding = MediaQuery.of(ctx).padding.top + 10;
        final width = MediaQuery.of(ctx).size.width * 0.9;
        return Positioned(
          top: topPadding,
          left: (MediaQuery.of(ctx).size.width - width) / 2,
          width: width,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(width: 1),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Venta de Rifa")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre del cliente
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre del Cliente',
                  border: border,
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
                onSaved: (v) => nombreCliente = v!.trim(),
              ),
              const SizedBox(height: 24),

              // Número comprado (campo numérico simple)
              TextFormField(
                initialValue: numeroComprado.toString(),
                decoration: InputDecoration(
                  labelText: 'Número Comprado (0 - 100)',
                  border: border,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa un número';
                  final n = int.tryParse(v);
                  if (n == null || n < 0 || n > 100) {
                    return 'El número debe estar entre 0 y 100';
                  }
                  return null;
                },
                onSaved: (v) =>
                numeroComprado = int.tryParse(v!.trim()) ?? numeroComprado,
              ),
              const SizedBox(height: 24),

              // Precio de compra
              DropdownButtonFormField<double>(
                decoration: InputDecoration(
                  labelText: 'Precio de Compra (\$)',
                  border: border,
                ),
                value: precioComprado,
                items: precios
                    .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text('\$${p.toStringAsFixed(2)}'),
                ))
                    .toList(),
                onChanged: (v) => setState(() => precioComprado = v),
                validator: (v) => v == null ? 'Selecciona un precio' : null,
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Guardar Venta'),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final result = await DatabaseHelper().addSale(
                        nombreCliente!,
                        numeroComprado,
                        precioComprado!,
                      );
                      if (result > 0) {
                        _showTopNotification(
                          'Venta registrada correctamente\n'
                              'Cliente: $nombreCliente\n'
                              'Número: ${numeroComprado.toString().padLeft(2, '0')}\n'
                              'Precio: \$${precioComprado!.toStringAsFixed(2)}',
                        );
                      } else {
                        _showTopNotification('Error al registrar la venta');
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FooterNav(currentIndex: 1),
    );
  }
}
