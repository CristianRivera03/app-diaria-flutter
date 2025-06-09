import 'package:diaria/Components/colors.dart';
import 'package:diaria/Views/login.dart';
import 'package:flutter/material.dart';
import '../Components/button.dart';
import '../Components/textfield.dart';
import '../JSON/users.dart';
import '../SQLite/database_helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final usrName = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final db = DatabaseHelper();

  Future<void> signUp() async {
    // 1) Campos obligatorios
    if (fullName.text.isEmpty ||
        email.text.isEmpty ||
        usrName.text.isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    // 2) Formato de email
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailPattern.hasMatch(email.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo electrónico válido.')),
      );
      return;
    }

    // 3) Fortaleza de contraseña
    //    - Al menos 8 caracteres
    //    - Al menos una letra mayúscula
    //    - Al menos un número
    final passPattern = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    if (!passPattern.hasMatch(password.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener al menos 8 caracteres, '
                'una letra mayúscula y un número.',
          ),
        ),
      );
      return;
    }

    // 4) Confirmar contraseñas
    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    // 5) Crear usuario en BD
    var result = await db.createUser(
      Users(
        fullName: fullName.text.trim(),
        email: email.text.trim(),
        usrName: usrName.text.trim(),
        usrPassword: password.text,
      ),
    );

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado exitosamente.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un problema al registrar el usuario.')),
      );
    }
  }

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    usrName.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Registrar nuevo usuario",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                InputField(
                  hint: "Nombre completo",
                  icon: Icons.person,
                  controller: fullName,
                ),
                InputField(
                  hint: "Email",
                  icon: Icons.email,
                  controller: email,
                ),
                InputField(
                  hint: "Nombre de usuario",
                  icon: Icons.account_circle,
                  controller: usrName,
                ),
                InputField(
                  hint: "Contraseña",
                  icon: Icons.lock,
                  controller: password,
                  passwordInvisible: true,
                ),
                InputField(
                  hint: "Repite la contraseña",
                  icon: Icons.lock,
                  controller: confirmPassword,
                  passwordInvisible: true,
                ),
                const SizedBox(height: 10),
                Button(
                  label: "Registrar",
                  press: signUp,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿Ya tienes una cuenta?",
                      style: TextStyle(color: primaryColor, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        "Iniciar sesión",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
