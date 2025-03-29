import 'package:diaria/Views/help_view.dart';
import 'package:flutter/material.dart';
import '../Components/button.dart';
import '../Components/colors.dart';
import '../JSON/users.dart';
import 'auth.dart';
import 'changePassword.dart';
import 'user_screen_list.dart';
import 'theme_settings_page.dart';

class Profile extends StatelessWidget {
  final Users? profile;

  const Profile({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Perfil"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: "Ayuda",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpView()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            tooltip: "Personalizar colores",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 45.0, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  radius: 77,
                  child: const CircleAvatar(
                    backgroundImage: AssetImage("assets/no user.png"),
                    radius: 75,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Bienvenido ${profile?.fullName}",
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${profile?.email}",
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Button(
                  label: "Logout",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: theme.primaryColor, size: 30),
                  subtitle: const Text("Nombre completo"),
                  title: Text("${profile?.fullName}"),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle, color: theme.primaryColor, size: 30),
                  subtitle: const Text("Usuario"),
                  title: Text("${profile?.usrName}"),
                ),
                ListTile(
                  leading: Icon(Icons.lock, color: theme.primaryColor, size: 30),
                  subtitle: const Text("Seguridad"),
                  title: const Text("Cambiar Contraseña"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(profile: profile!),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.email, color: theme.primaryColor, size: 30),
                  subtitle: const Text("Correo electrónico"),
                  title: Text("${profile?.email}"),
                ),
                ListTile(
                  leading: Icon(Icons.list, color: theme.primaryColor, size: 30),
                  subtitle: const Text("Gestionar usuarios"),
                  title: const Text("Lista de Usuarios"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserListScreen(
                          currentUserName: profile?.usrName ?? "",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
