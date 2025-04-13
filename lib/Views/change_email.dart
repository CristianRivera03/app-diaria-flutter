import 'package:flutter/material.dart';
import '../Components/button.dart';
import '../SQLite/database_helper.dart';
import '../JSON/users.dart';

class ChangeEmailScreen extends StatefulWidget {
  final Users profile;

  const ChangeEmailScreen({super.key, required this.profile});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.profile.email!; // Prellenar el correo actual
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _updateEmail() async {
    String newEmail = _emailController.text.trim();

    if (newEmail.isEmpty || !isValidEmail(newEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, introduce un correo válido')),
      );
      return;
    }

    bool emailTaken = await DatabaseHelper().isEmailTaken(newEmail);
    if (emailTaken) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El correo ingresado ya está en uso')),
      );
      return;
    }

    try {
      bool success = await DatabaseHelper().updateEmail(widget.profile.email!, newEmail);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correo actualizado con éxito')),
        );
        Navigator.pop(context, newEmail);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el correo. Intenta nuevamente.')),
        );
      }
    } catch (e) {
      print('Error al actualizar el correo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error inesperado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Obtener el tema

    return Scaffold(
      appBar: AppBar(
        title: Text("Cambiar Correo Electrónico"),
        backgroundColor: theme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Introduce tu nuevo correo electrónico",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Nuevo Correo Electrónico",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: theme.primaryColor), // Color del texto
              ),
            ),
            SizedBox(height: 20),
            Button(
              label: "Actualizar Correo",
              press: _updateEmail,
              color: theme.primaryColor,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancelar y regresar a perfil
              },
              child: Text("Cancelar", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            ),
          ],
        ),
      ),
    );
  }
}
