import 'package:diaria/Components/button.dart';
import 'package:diaria/Components/colors.dart';
import 'package:diaria/Views/signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Components/textfield.dart';
import '../JSON/users.dart';
import '../SQLite/database_helper.dart';
import 'forgotPassword.dart';
import 'package:diaria/Views/main_view.dart'; // IMPORTACIÓN DE MAIN VIEW

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usrName = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isPasswordVisible = false;
  bool isChecked = false;
  bool isLoginError = false;
  bool isBlocked = false;
  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
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
      // Recupera los datos del usuario
      Users? userDetails = await db.getUser(usrName.text);

      if (userDetails != null) {
        await saveCredentials();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainView(userProfile: userDetails)),
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
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
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
                    obscureText: !isPasswordVisible,
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
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoginError)
                  Text(
                    "Usuario o contraseña incorrectos.",
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
