import 'package:diaria/Views/help_view.dart';
import 'package:flutter/material.dart';
import '../Components/button.dart';
import '../Components/colors.dart';
import '../JSON/users.dart';
import '../SQLite/database_helper.dart';
import 'auth.dart';
import 'changePassword.dart';
import 'change_email.dart';
import 'user_screen_list.dart';
import 'user_status_list.dart'; // Nueva importación para la lista de estado de usuarios
import 'theme_settings_page.dart';

class Profile extends StatefulWidget {
  final Users? profile;

  const Profile({super.key, this.profile});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isActive = false; // Estado inicial del usuario

  @override
  void initState() {
    super.initState();
    fetchUserStatus(); // Obtener estado de conexión inicial
  }

  Future<void> fetchUserStatus() async {
    final db = DatabaseHelper();
    Users? user = await db.getUser(widget.profile!.usrName);
    if (user != null) {
      setState(() {
        isActive = user.isActive;
      });
    }
  }

  Future<void> toggleUserStatus(bool status) async {
    final db = DatabaseHelper();
    await db.updateConnectionStatus(widget.profile!.usrName, status);
    setState(() {
      isActive = status;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status ? "Estás ahora Activo." : "Estás ahora Desconectado.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Perfil"),
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
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 75,
                  backgroundImage: const AssetImage("assets/no user.png"),
                ),
                const SizedBox(height: 10),
                Text(
                  "Bienvenido ${widget.profile?.fullName}",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Estado:",
                      style: TextStyle(fontSize: 18),
                    ),
                    Switch(
                      value: isActive,
                      onChanged: toggleUserStatus,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                  leading: Icon(Icons.person, size: 30, color: Theme.of(context).primaryColor),
                  subtitle: const Text("Nombre completo"),
                  title: Text("${widget.profile?.fullName}"),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle, size: 30, color: Theme.of(context).primaryColor),
                  subtitle: const Text("Usuario"),
                  title: Text("${widget.profile?.usrName}"),
                ),
                ListTile(
                  leading: Icon(Icons.lock, size: 30, color: Theme.of(context).primaryColor),
                  subtitle: const Text("Seguridad"),
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
                  leading: Icon(Icons.email, size: 30, color: Theme.of(context).primaryColor),
                  subtitle: const Text("Correo Electrónico"),
                  title: Text("${widget.profile?.email}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeEmailScreen(profile: widget.profile!),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.list, size: 30, color: Theme.of(context).primaryColor),
                  subtitle: const Text("Bloqueo de Usuarios"),
                  title: const Text("Lista de Bloqueo"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserListScreen(currentUserName: widget.profile?.usrName ?? ""),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.network_check, size: 30, color: Theme.of(context).primaryColor),
                  subtitle: const Text("Estado de Usuarios"),
                  title: const Text("Lista de Estado"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserStatusListScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20), // Espaciado
                Button(
                  label: "Eliminar Cuenta",
                  press: () => _showDeleteConfirmationDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Eliminación"),
          content: const Text(
            "¿Estás seguro de que quieres eliminar tu cuenta? Esta acción es irreversible.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Cierra el diálogo primero
                await _deleteUserAccount(context); // Luego procede con la eliminación
              },
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUserAccount(BuildContext context) async {
    final db = DatabaseHelper();

    try {
      final String currentUserEmail = widget.profile!.email!;
      bool success = await db.deleteUserAccount(currentUserEmail);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cuenta eliminada con éxito.")),
        );

        // Redirige al inicio de sesión
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al eliminar la cuenta. Inténtalo de nuevo.")),
        );
      }
    } catch (e) {
      print("Error al eliminar la cuenta: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ocurrió un error inesperado. Inténtalo más tarde.")),
      );
    }
  }
}