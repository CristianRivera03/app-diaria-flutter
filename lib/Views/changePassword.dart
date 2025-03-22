import 'package:flutter/material.dart';
import '../Components/button.dart';
import '../Components/colors.dart';
import '../SQLite/database_helper.dart';
import '../JSON/users.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Users profile; // Se pasa el perfil del usuario actual

  const ChangePasswordScreen({super.key, required this.profile});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isProcessing = false;
  final DatabaseHelper db = DatabaseHelper();

  Future<void> _changePassword() async {
    // Validación de campos
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas nuevas no coinciden')),
      );
      return;
    }

    // Verificar si la contraseña actual es correcta
    setState(() {
      _isProcessing = true;
    });

    bool isAuthenticated = await db.authenticate(
      Users(usrName: widget.profile.usrName, usrPassword: currentPassword),
    );

    if (!isAuthenticated) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La contraseña actual es incorrecta')),
      );
      return;
    }

    // Actualizar la contraseña en la base de datos
    bool success = await db.changePassword(widget.profile.usrName, currentPassword, newPassword);

    setState(() {
      _isProcessing = false;
    });

    String message = success
        ? 'Contraseña actualizada exitosamente'
        : 'Hubo un error al actualizar la contraseña';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (success) {
      Navigator.pop(context); // Vuelve al perfil
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar Contraseña'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cambia tu contraseña',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña Actual',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar Nueva Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            _isProcessing
                ? Center(child: CircularProgressIndicator())
                : Button(
              label: 'Actualizar Contraseña',
              press: _changePassword,
            ),
          ],
        ),
      ),
    );
  }
}