import 'package:flutter/material.dart';

import '../Components/button.dart';
import '../Components/colors.dart';
import '../JSON/users.dart';
import 'auth.dart';

class Profile extends StatelessWidget {
  final Users? profile;
  const Profile({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 45.0, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor,
                  radius: 77,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/no user.png"),
                    radius: 75,
                  ),
                ),

                SizedBox(height: 10),
                Text("Bienvenido ${profile?.fullName}", style: TextStyle(color: primaryColor, fontSize: 30, fontWeight: FontWeight.bold),),
                Text("${profile?.email}", style: TextStyle(color: Colors.black45, fontSize: 15, fontWeight: FontWeight.bold),),

                Button(label: "Logout", press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                }),

                // Informacion del usuario
                ListTile(
                  leading: Icon(Icons.person, color: primaryColor, size: 30,),
                  subtitle: Text("Nombre completo"),
                  title: Text("${profile?.fullName}"),
                ),

                // Informacion del usuario correo
                 ListTile(
                  leading: Icon(Icons.account_circle, color: primaryColor, size: 30,),
                  subtitle: Text("Usuario"),
                  title: Text("${profile?.usrName}"),
                ),


                // Informacion del usuario correo
                ListTile(
                  leading: Icon(Icons.email, color: primaryColor, size: 30,),
                  subtitle: Text("Correo electronico"),
                  title: Text("${profile?.email}"),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
