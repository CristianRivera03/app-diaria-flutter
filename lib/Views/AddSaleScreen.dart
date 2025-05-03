import 'package:flutter/material.dart';
import '../SQLite/database_helper.dart';


class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  String? nombreCliente;
  int? numeroComprado;
  double? precioComprado;

  final List<int> numeros = List.generate(101, (index) => index); // 00 al 100
  final List<double> precios = List.generate(20, (index) => (index + 1) * 0.25); // 0.25 a 5.00

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Venta de Rifa"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo para el nombre
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  nombreCliente = value!.trim();
                },
              ),
              const SizedBox(height: 20),

              // Dropdown para el número comprado
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Número Comprado (00 - 100)'),
                value: numeroComprado,
                items: numeros
                    .map((num) => DropdownMenuItem(
                  value: num,
                  child: Text(num.toString().padLeft(2, '0')),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    numeroComprado = value;
                  });
                },
                validator: (value) => value == null ? 'Selecciona un número' : null,
              ),
              const SizedBox(height: 20),

              // Dropdown para el precio
              DropdownButtonFormField<double>(
                decoration: const InputDecoration(labelText: 'Precio de Compra (\$)'),
                value: precioComprado,
                items: precios
                    .map((precio) => DropdownMenuItem(
                  value: precio,
                  child: Text('\$${precio.toStringAsFixed(2)}'),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    precioComprado = value;
                  });
                },
                validator: (value) => value == null ? 'Selecciona un precio' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      int result = await DatabaseHelper().addSale(
                        nombreCliente!,
                        numeroComprado!,
                        precioComprado!,
                      );

                      if (result > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Venta registrada correctamente')),
                        );
                        Navigator.pop(context); // Opcional: cerrar pantalla
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al registrar la venta')),
                        );
                      }
                    }
                  },

                child: const Text('Guardar Venta'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
