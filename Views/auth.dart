import 'package:diaria/Components/colors.dart';
import 'package:flutter/material.dart';

import '../Components/button.dart';
import 'login.dart';
import 'signup.dart';


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Bienvenid@",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  "¿Que quieres hacer?",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),

                Expanded(child:
                Image.asset("assets/imgUno.png")),
                Button(label: "Iniciar Sesion", press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                }),

                Button(label: "Registrarse", press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));

                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
