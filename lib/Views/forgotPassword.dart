import 'package:diaria/Components/button.dart';
import 'package:diaria/Components/colors.dart';
import 'package:flutter/material.dart';
import '../Components/textfield.dart';
import '../SQLite/database_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPsswdScreen();
}

class _ForgotPsswdScreen extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Método para manejar el reseteo de contraseña
  Future<void> resetPassword() async {
    String email = _emailController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    if (email.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    bool success = await DatabaseHelper().resetPassword(email, newPassword);

    String message = success
        ? 'Contraseña restablecida exitosamente. Intenta iniciar sesión.'
        : 'Correo electrónico no encontrado.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (success) {
      // Navegar de regreso a la pantalla de inicio de sesión, si es necesario
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar Contraseña'),
        backgroundColor: Colors.white, // Color desde el archivo colors.dart
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recuperar Contraseña",
              style: TextStyle(
                color: primaryColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.asset("assets/imgDos.png"), // Usa el mismo recurso que en Login
            InputField(
              hint: "Correo Electrónico",
              icon: Icons.email,
              controller: _emailController,
            ),
            InputField(
              hint: "Nueva Contraseña",
              icon: Icons.lock,
              controller: _newPasswordController,
              passwordInvisible: true,
            ),
            Button(
              label: "Restablecer Contraseña",
              press: () => resetPassword(),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Volver al Login
              },
              child: Text(
                "Cancelar",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}