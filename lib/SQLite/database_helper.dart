
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../JSON/users.dart';

class DatabaseHelper {
  final databaseName = "diaria.db";

  // Tablas
  String user = ''' 
  CREATE TABLE users (
    usrId INTEGER PRIMARY KEY AUTOINCREMENT,
    fullName TEXT,
    email TEXT,
    usrName TEXT,
    usrPassword TEXT
  )
  ''';

  // Crear la base de datos
  Future<Database> initDB() async {
    // Obtener la ruta de la base de datos
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(user);
      },
    );
  }

  //Autenticar usuario
  Future<bool> authenticate(Users usr) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
      "select * from users WHERE usrName = '${usr
          .usrName}' AND usrPassword = '${usr.usrPassword}'",
    );
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

// Registrar usuario
  Future<int> createUser(Users usr) async {
    final Database db = await initDB();
    return db.insert("users", usr.toMap());
  }

  // Obtener informacion del usuario actual
  Future<Users?> getUser(String usrName) async {
    final Database db = await initDB();
    var res = await db.query(
      "users" , where: "usrName = ?", whereArgs: [usrName]);
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }
}