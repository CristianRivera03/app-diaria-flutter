import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../SQLite/database_helper.dart';

class EmailService {
  final String username = 'axodev.assistance@gmail.com'; // Tu correo
  final String password = 'vpagwbrjaxoailgv'; // Contraseña de aplicación

  Future<void> sendPasswordResetEmail(String recipientEmail, String body) async {
    try {
      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'Soporte App Diaria')
        ..recipients.add(recipientEmail)
        ..subject = 'Restablecimiento de Contraseña'
        ..text = body;

      await send(message, smtpServer);
      print('Correo enviado exitosamente');
    } catch (e) {
      print('Error al enviar correo: $e');
      rethrow; // Manejar errores de envío de correo
    }
  }

  Future<void> sendVerificationCode(String email) async {
    final code = generateVerificationCode();

    // Almacenar el código
    await DatabaseHelper().storeVerificationCode(email, code);

    // Construir el cuerpo del correo
    final body = '''
    Hola,
    Tu código de verificación es: $code.
    Por favor, ingrésalo en la aplicación para restablecer tu contraseña.
  ''';

    await sendPasswordResetEmail(email, body);
  }

  String generateVerificationCode() {
    final random = Random();
    final code = List.generate(6, (_) => random.nextInt(10)).join(); // Código de 6 dígitos
    return code;
  }
}