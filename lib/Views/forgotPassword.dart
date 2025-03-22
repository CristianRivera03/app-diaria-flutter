import 'package:diaria/Views/verifyCode.dart';
import 'package:flutter/material.dart';
import '../Components/button.dart';
import '../Components/colors.dart';
import '../Components/textfield.dart';
import '../Services/email_services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> sendVerificationCode() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, introduce un correo electrónico')),
      );
      return;
    }

    try {
      // Generar y enviar el código
      final emailService = EmailService();
      await emailService.sendVerificationCode(email);

      // Redirigir al usuario a la pantalla de verificación de código
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerifyCodeScreen(email: email)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el correo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar Contraseña'),
        backgroundColor: primaryColor,
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
            SizedBox(height: 20),
            InputField(
              hint: "Correo Electrónico",
              icon: Icons.email,
              controller: _emailController,
            ),
            SizedBox(height: 20),
            Button(
              label: "Enviar Código",
              press: sendVerificationCode,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
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