import 'package:diaria/Views/profile.dart';
import 'package:diaria/Views/viewContactScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Asegúrate de importar Provider

import '../JSON/users.dart';
import 'add_contact_screen.dart';
import 'help_view.dart';
import '../Services/theme_manager.dart'; // Importa el ThemeManager

class MainView extends StatelessWidget {
  final Users userProfile; // Recibe el perfil del usuario

  const MainView({super.key, required this.userProfile}); // Constructor actualizado

  @override
  Widget build(BuildContext context) {
    // Accedemos al ThemeManager a través del Provider
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeManager.primaryColor, // Usamos el color primario del tema
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32),
            onPressed: () {
              // Navegar al perfil pasando el objeto userProfile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(profile: userProfile),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomMainButton(
              text: 'Agregar Cliente',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddContactScreen()), // Navega a AddContactScreen
                );
              },
            ),
            const SizedBox(height: 20),
            CustomMainButton(
              text: 'Ver contactos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewContactScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomMainButton(
              text: 'Lorem',
              onPressed: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: themeManager.primaryColor, // Usamos el color primario del tema
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'home',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class CustomMainButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomMainButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context); // Accedemos al ThemeManager

    return SizedBox(
      width: 300,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeManager.primaryColor, // Usamos el color primario del tema
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: themeManager.textColor, // Usamos el color de texto del tema
          ),
        ),
      ),
    );
  }
}
