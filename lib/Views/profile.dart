import 'package:flutter/material.dart';
import '../Components/button.dart';
import '../Components/colors.dart';
import '../JSON/users.dart';
import '../SQLite/database_helper.dart';
import 'auth.dart';
import 'changePassword.dart';
import 'user_screen_list.dart';

class Profile extends StatelessWidget {
  final Users? profile;

  const Profile({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Text(
                  "Bienvenido ${profile?.fullName}",
                  style: TextStyle(color: primaryColor, fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${profile?.email}",
                  style: TextStyle(color: Colors.black45, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Button(label: "Logout", press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                }),
                ListTile(
                  leading: Icon(Icons.person, color: primaryColor, size: 30),
                  subtitle: Text("Nombre completo"),
                  title: Text("${profile?.fullName}"),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle, color: primaryColor, size: 30),
                  subtitle: Text("Usuario"),
                  title: Text("${profile?.usrName}"),
                ),
                ListTile(
                  leading: Icon(Icons.lock, color: primaryColor, size: 30),
                  subtitle: Text("Seguridad"),
                  title: Text("Cambiar Contraseña"),
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
                  leading: Icon(Icons.email, color: primaryColor, size: 30),
                  subtitle: Text("Correo electrónico"),
                  title: Text("${profile?.email}"),
                ),
                ListTile(
                  leading: Icon(Icons.list, color: primaryColor, size: 30),
                  subtitle: Text("Gestionar usuarios"),
                  title: Text("Lista de Usuarios"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserListScreen(currentUserName: profile?.usrName ?? ""),
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