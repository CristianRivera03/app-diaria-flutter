import 'package:flutter/material.dart';
import '../SQLite/database_helper.dart';
import '../JSON/users.dart';

class UserStatusListScreen extends StatefulWidget {
  const UserStatusListScreen({Key? key}) : super(key: key);

  @override
  _UserStatusListScreenState createState() => _UserStatusListScreenState();
}

class _UserStatusListScreenState extends State<UserStatusListScreen> {
  List<Users> users = [];
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    fetchUsersStatus(); // Cargar la lista de estados de usuarios
  }

  Future<void> fetchUsersStatus() async {
    final allUsers = await dbHelper.getAllUsers();
    setState(() {
      users = allUsers; // Mostrar todos los usuarios con su estado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estado de Usuarios"),
      ),
      body: users.isEmpty
          ? const Center(
        child: Text(
          "No hay usuarios disponibles.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.usrName),
            subtitle: Text(
              user.isActive ? "Conectado" : "Desconectado",
              style: TextStyle(
                color: user.isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}