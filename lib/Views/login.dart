import 'package:diaria/Components/button.dart';
import 'package:diaria/Components/colors.dart';
import 'package:diaria/Views/profile.dart';
import 'package:diaria/Views/signup.dart';
import 'package:flutter/material.dart';
import '../Components/textfield.dart';
import '../JSON/users.dart';
import '../SQLite/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usrName = TextEditingController();
  final password = TextEditingController();
  bool isChecked = false;
  bool isLoginError = false;
  bool isBlocked = false;
  final db = DatabaseHelper();

  Future<void> login() async {
    isBlocked = await db.isUserBlocked(usrName.text);

    if (isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El usuario está bloqueado y no puede acceder.', style: TextStyle(color: Colors.red)),
        ),
      );
      return;
    }

    var userAuthenticated = await db.authenticate(
      Users(usrName: usrName.text, usrPassword: password.text),
    );

    if (userAuthenticated) {
      Users? userDetails = await db.getUser(usrName.text);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Profile(profile: userDetails)),
      );
    } else {
      setState(() {
        isLoginError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Iniciar Sesión",
                  style: TextStyle(color: primaryColor, fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Image.asset("assets/imgDos.png"),
                InputField(hint: "Usuario", icon: Icons.person, controller: usrName),
                InputField(hint: "Contraseña", icon: Icons.lock, controller: password, passwordInvisible: true),
                ListTile(
                  horizontalTitleGap: 2,
                  title: const Text("Recuérdame"),
                  leading: Checkbox(
                    activeColor: primaryColor,
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                ),
                Button(label: "Iniciar Sesión", press: () => login()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "¿No tienes una cuenta?",
                      style: TextStyle(color: primaryColor, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                      },
                      child: Text(
                        "Registrarme",
                        style: TextStyle(color: primaryColor, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (isLoginError)
                  Text(
                    "Usuario o contraseña incorrectos.",
                    style: TextStyle(color: Colors.red.shade900, fontSize: 15),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}