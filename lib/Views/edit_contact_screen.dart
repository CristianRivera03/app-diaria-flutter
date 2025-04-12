import 'package:flutter/material.dart';
import '../SQLite/database_helper.dart';
import 'package:provider/provider.dart'; // Asegúrate de importar Provider
import '../Services/theme_manager.dart'; // Importa el ThemeManager

class EditContactScreen extends StatefulWidget {
  final Map<String, dynamic> contact;

  const EditContactScreen({Key? key, required this.contact}) : super(key: key);

  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final dbHelper = DatabaseHelper();
  late TextEditingController fullNameController;
  late TextEditingController contactNumberController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.contact['fullName']);
    contactNumberController = TextEditingController(text: widget.contact['contactNumber']);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateContact() async {
    try {
      await dbHelper.updateContact(
        widget.contact['contactId'],
        fullNameController.text,
        contactNumberController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cliente actualizado exitosamente")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar cliente: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accedemos al ThemeManager a través del Provider
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Cliente"),
        backgroundColor: themeManager.primaryColor, // Usamos el color primario del tema
        foregroundColor: themeManager.textColor, // Usamos el color del texto
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: "Nombre Completo",
                labelStyle: TextStyle(color: themeManager.textColor), // Usamos el color de texto del tema
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: themeManager.primaryColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: themeManager.primaryColor),
                ),
              ),
              style: TextStyle(color: themeManager.textColor), // Usamos el color de texto del tema
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contactNumberController,
              decoration: InputDecoration(
                labelText: "Número de Cliente",
                labelStyle: TextStyle(color: themeManager.textColor), // Usamos el color de texto del tema
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: themeManager.primaryColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: themeManager.primaryColor),
                ),
              ),
              style: TextStyle(color: themeManager.textColor), // Usamos el color de texto del tema
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeManager.primaryColor, // Fondo del botón
                foregroundColor: themeManager.textColor, // Color del texto
                padding: const EdgeInsets.symmetric(vertical: 16.0), // Espaciado vertical
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
                ),
              ),
              child: const Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
