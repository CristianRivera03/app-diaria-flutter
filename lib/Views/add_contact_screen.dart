import 'package:flutter/material.dart';
import '../Components/footer_nav.dart';
import '../SQLite/database_helper.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({Key? key}) : super(key: key);

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final dbHelper = DatabaseHelper();

  Future<void> _addContact() async {
    if (!_formKey.currentState!.validate()) return;
    final numero = _contactNumberController.text.trim();

    // 1) Consulta duplicados
    final existentes = await dbHelper.getContactsByNumber(numero);
    if (existentes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ya existe un cliente con ese número.")),
      );
      return;
    }

    // 2) Si no hay duplicado, inserta
    try {
      final result = await dbHelper.addContact(
        _fullNameController.text.trim(),
        numero,
      );
      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cliente agregado exitosamente.")),
        );
        _fullNameController.clear();
        _contactNumberController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al agregar el cliente.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Cliente"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre Completo: mínimo 4 caracteres
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: "Nombre Completo",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Por favor ingresa un nombre completo.";
                  }
                  if (value.trim().length < 4) {
                    return "El nombre debe tener al menos 4 letras.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Número de Cliente: exactamente 8 dígitos
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(
                  labelText: "Número de Cliente",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Por favor ingresa un número de cliente.";
                  }
                  final trimmed = value.trim();
                  if (!RegExp(r'^\d{8}$').hasMatch(trimmed)) {
                    return "El número debe tener exactamente 8 dígitos.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  "Registrar Cliente",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FooterNav(currentIndex: 3),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }
}
