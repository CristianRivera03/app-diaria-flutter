import 'package:diaria/Components/button.dart';
import 'package:diaria/Components/colors.dart';
import 'package:diaria/Views/profile.dart';
import 'package:diaria/Views/signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar para guardar datos
import '../JSON/users.dart';
import '../SQLite/database_helper.dart';
import 'forgotPassword.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usrName = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isPasswordVisible = false; // Estado de visibilidad de la contraseña
  bool isChecked = false; // Estado del checkbox para recordar usuario
  bool isLoginError = false; // Estado de error en el login
  bool isBlocked = false; // Estado de usuario bloqueado
  final db = DatabaseHelper(); // Instancia de la base de datos

  @override
  void initState() {
    super.initState();
    loadSavedCredentials(); // Cargar credenciales guardadas al iniciar la app
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usrName.text = prefs.getString('usrName') ?? '';
      password.text = prefs.getString('password') ?? '';
      isChecked = prefs.getBool('isChecked') ?? false;
    });
  }

  Future<void> saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      await prefs.setString('usrName', usrName.text);
      await prefs.setString('password', password.text);
      await prefs.setBool('isChecked', true);
    } else {
      await prefs.remove('usrName');
      await prefs.remove('password');
      await prefs.setBool('isChecked', false);
    }
  }

  Future<void> login() async {
    if (usrName.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    isBlocked = await db.isUserBlocked(usrName.text);

    if (isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El usuario está bloqueado y no puede acceder.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      return;
    }

    var userAuthenticated = await db.authenticate(
      Users(usrName: usrName.text, usrPassword: password.text),
    );

    if (userAuthenticated) {
      await saveCredentials(); // Guardar o eliminar credenciales según el estado del checkbox

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 1.0),
                  child: TextField(
                    controller: usrName,
                    decoration: InputDecoration(
                      hintText: "Usuario",
                      prefixIcon: Icon(Icons.person),
                      fillColor: Colors.blue.shade50,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: TextField(
                    controller: password,
                    obscureText: !isPasswordVisible, // Se controla si se ve o no la contraseña
                    decoration: InputDecoration(
                      hintText: "Contraseña",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      fillColor: Colors.blue.shade50,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
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
                Button(label: "Iniciar Sesión", press: login),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        "Olvidé mi contraseña",
                        style: TextStyle(color: primaryColor, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "¿No tienes una cuenta?",
                      style: TextStyle(color: primaryColor, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
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
