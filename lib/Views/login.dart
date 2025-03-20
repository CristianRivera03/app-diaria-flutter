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
  // Controladores para los campos de texto
  final usrName = TextEditingController();
  final password = TextEditingController();

  bool isChecked = false;
  bool isLoginTrue = false;
  final db = DatabaseHelper();
  // funcion para autenticar el usuario
  login() async{
    Users? userDetails = await db.getUser(usrName.text);
    var res = await db.authenticate(Users(usrName: usrName.text, usrPassword: password.text));
    if(res == true){
      // si el login es correcto se dirige a la pantalla de perfil
      if(!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) =>  Profile(profile: userDetails,)));
    }else{
      setState(() {
        isLoginTrue = true;
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
                  "Iniciar Sesion",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.asset("assets/imgDos.png"),
                InputField(
                  hint: "Usuario",
                  icon: Icons.person,
                  controller: usrName,
                ),
                InputField(
                  hint: "Contraseña",
                  icon: Icons.lock,
                  controller: password,
                  passwordInvisible: true,
                ),
                ListTile(
                  horizontalTitleGap: 2,
                  title: const Text("Recuerdame"),
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
                Button(label: "Iniciar Sesion", press: () {
                  login();
                }),

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
                      child: const Text(
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


                // esto se tiene que ocultar y solo monstrar cuando el login sea incorrecto
                // si el login es correcto, se oculta
                isLoginTrue ? Text("Usuario o contraseña incorrectos" , style: TextStyle(color: Colors.red.shade900, fontSize: 15),): const SizedBox(),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
