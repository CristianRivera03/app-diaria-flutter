import 'package:diaria/Views/setNewPassword.dart';
import 'package:flutter/material.dart';
import '../Components/button.dart';
import '../SQLite/database_helper.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _codeController = TextEditingController();

  Future<void> verifyCode() async {
    String enteredCode = _codeController.text.trim();
    if (enteredCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, introduce el código de verificación')),
      );
      return;
    }

    bool isValid = await DatabaseHelper().verifyCode(widget.email, enteredCode);

    if (isValid) {
      // Redirigir al usuario a la pantalla para establecer nueva contraseña
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SetNewPasswordScreen(email: widget.email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código incorrecto, inténtalo de nuevo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificar Código'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Introduce el código que enviamos a tu correo',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Código de verificación",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Button(
              label: "Verificar Código",
              press: verifyCode,
            ),
          ],
        ),
      ),
    );
  }
}