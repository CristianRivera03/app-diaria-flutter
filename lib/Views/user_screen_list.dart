import 'package:flutter/material.dart';
import '../SQLite/database_helper.dart';

class UserListScreen extends StatefulWidget {
  final String currentUserName;

  const UserListScreen({required this.currentUserName, Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> users = [];
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final db = await dbHelper.initDB();
    final List<Map<String, dynamic>> allUsers = await db.query("users");
    final filteredUsers = allUsers.where((user) => user['usrName'] != widget.currentUserName).toList();
    setState(() {
      users = filteredUsers;
    });
  }

  Future<void> blockUser(String usrName) async {
    await dbHelper.blockUser(usrName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$usrName ha sido bloqueado.')),
    );
    fetchUsers();
  }

  Future<void> unblockUser(String usrName) async {
    await dbHelper.unblockUser(usrName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$usrName ha sido desbloqueado.')),
    );
    fetchUsers();
  }

  Future<bool> isBlocked(String usrName) async {
    return await dbHelper.isUserBlocked(usrName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("Lista de Usuarios"),
    ),
    body: ListView.builder(
    itemCount: users.length,
    itemBuilder: (context, index) {
    final user = users[index];
    return FutureBuilder<bool>(
    future: isBlocked(user['usrName']),
    builder: (context, snapshot) {
    if (!snapshot.hasData) {
    return ListTile(
    title: Text(user['usrName']),
    trailing: CircularProgressIndicator(),
    );
    }

    final isUserBlocked = snapshot.data ?? false;

    return ListTile(
      title: Text(user['usrName']),
      subtitle: isUserBlocked
          ? Text("Bloqueado", style: TextStyle(color: Colors.red))
          : Text("Activo", style: TextStyle(color: Colors.green)),
      trailing: isUserBlocked
          ? IconButton(
        icon: Icon(Icons.lock_open, color: Colors.green),
        onPressed: () => unblockUser(user['usrName']),
      )
          : IconButton(
        icon: Icon(Icons.block, color: Colors.red),
        onPressed: () => blockUser(user['usrName']),
      ),
    );
    },
    );
    },
    ),
    );
  }
}