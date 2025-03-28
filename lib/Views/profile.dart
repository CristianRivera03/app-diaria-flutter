import 'package:diaria/Views/help_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar SharedPreferences
import '../Components/button.dart';
import '../Components/colors.dart';
import '../JSON/users.dart';
import 'auth.dart';
import 'changePassword.dart';
import 'user_screen_list.dart';
import '../Components/navbar.dart';

class Profile extends StatefulWidget {
  final Users? profile;

  const Profile({super.key, this.profile});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isDarkMode = false; // Estado para el tema oscuro

  @override
  void initState() {
    super.initState();
    loadThemePreference(); // Cargar preferencia del tema al inicializar
  }

  // Cargar la preferencia del tema desde SharedPreferences
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Guardar la preferencia del tema en SharedPreferences
  Future<void> toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Gestión de Perfil",
        onLeftTap: () {}, // Función vacía en lugar de null
        onRightTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpView()),
          );
        },
      ),
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
                const SizedBox(height: 10),
                Text(
                  "Bienvenido ${widget.profile?.fullName}",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${widget.profile?.email}",
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
                  leading: Icon(Icons.person, color: primaryColor, size: 30),
                  subtitle: Text("Nombre completo"),
                  title: Text("${widget.profile?.fullName}"),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle, color: primaryColor, size: 30),
                  subtitle: Text("Usuario"),
                  title: Text("${widget.profile?.usrName}"),
                ),
                ListTile(
                  leading: Icon(Icons.lock, color: primaryColor, size: 30),
                  subtitle: Text("Seguridad"),
                  title: const Text("Cambiar Contraseña"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(profile: widget.profile!),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.email, color: primaryColor, size: 30),
                  subtitle: const Text("Correo electrónico"),
                  title: Text("${widget.profile?.email}"),
                ),
                ListTile(
                  leading: Icon(Icons.list, color: primaryColor, size: 30),
                  subtitle: const Text("Gestionar usuarios"),
                  title: const Text("Lista de Usuarios"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserListScreen(
                          currentUserName: widget.profile?.usrName ?? "",
                        ),
                      ),
                    );
                  },
                ),
                // Nueva opción: Configuración de Tema
                ListTile(
                  leading: Icon(Icons.brightness_6, color: primaryColor, size: 30),
                  subtitle: const Text("Tema de la aplicación"),
                  title: const Text("Modo Oscuro"),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) => toggleTheme(value), // Cambiar el tema
                    activeColor: Colors.blue,
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