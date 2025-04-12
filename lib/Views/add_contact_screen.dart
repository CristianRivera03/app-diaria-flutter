import 'package:flutter/material.dart';
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
    if (_formKey.currentState!.validate()) {
      try {
        final int result = await dbHelper.addContact(
          _fullNameController.text.trim(),
          _contactNumberController.text.trim(),
        );
        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Contacto agregado exitosamente.")),
          );
          _fullNameController.clear();
          _contactNumberController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al agregar el contacto.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Contacto"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: "Nombre Completo",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa un nombre completo.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(
                  labelText: "Número de Contacto",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa un número de contacto.";
                  }
                  if (value.length < 8) {
                    return "El número debe tener al menos 8 dígitos.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor, // Usar el color principal del tema
                ),
                child: Text(
                  "Registrar Contacto",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color, // Usar el color de texto del tema
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }
}
