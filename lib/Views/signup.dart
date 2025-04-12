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
    if (fullName.text.isEmpty || email.text.isEmpty || usrName.text.isEmpty || password.text.isEmpty || confirmPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    var result = await db.createUser(
      Users(
        fullName: fullName.text,
        email: email.text,
        usrName: usrName.text,
        usrPassword: password.text,
      ),
    );

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario registrado exitosamente.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hubo un problema al registrar el usuario.')),
      );
    }
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
                InputField(hint: "Nombre completo", icon: Icons.person, controller: fullName),
                InputField(hint: "Email", icon: Icons.email, controller: email),
                InputField(hint: "Nombre de usuario", icon: Icons.account_circle, controller: usrName),
                InputField(hint: "Contraseña", icon: Icons.lock, controller: password, passwordInvisible: true),
                InputField(hint: "Ingresa contraseña de nuevo", icon: Icons.lock, controller: confirmPassword, passwordInvisible: true),
                const SizedBox(height: 10),
                Button(
                  label: "Registrar",
                  press: () => signUp(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿Ya tienes una cuenta?", style: TextStyle(color: primaryColor, fontSize: 15)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        "Iniciar sesión",
                        style: TextStyle(color: primaryColor, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}