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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeEmailScreen(profile: profile!),
                      ),
                    );
                  },
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
                SizedBox(height: 20), // Espaciado
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

  // Metodo para mostrar el cuadro de diálogo de confirmación
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
          title: Text("Confirmar Eliminación"),
          content: Text(
            "¿Estás seguro de que quieres eliminar tu cuenta? Esta acción es irreversible y toda tu información será eliminada.",
          ),
          actions: [
          TextButton(
          onPressed: () {
        Navigator.pop(context); // Cierra el cuadro de diálogo
      },
    child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
    ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Cierra el cuadro de diálogo primero
                await _deleteUserAccount(context); // Luego procede con la eliminación
              },
              child: Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
      );
        },
    );
  }
// Metodo para eliminar el usuario
  Future<void> _deleteUserAccount(BuildContext context) async {
    final db = DatabaseHelper();

    try {
      // Asegúrate de que el usuario esté disponible
      final String currentUserEmail = profile!.email!;
      bool success = await db.deleteUserAccount(currentUserEmail);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cuenta eliminada con éxito.")),
        );

        // Redirige al inicio de sesión
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar la cuenta. Inténtalo de nuevo.")),
        );
      }
    } catch (e) {
      print("Error al eliminar la cuenta: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ocurrió un error inesperado. Por favor, intenta más tarde.")),
      );
    }
  }
}
