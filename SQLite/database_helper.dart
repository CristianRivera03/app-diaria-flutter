import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../JSON/users.dart';

class DatabaseHelper {
  final databaseName = "diaria.db";

  final String userTable = ''' 
  CREATE TABLE users (
    usrId INTEGER PRIMARY KEY AUTOINCREMENT,
    fullName TEXT,
    email TEXT,
    usrName TEXT UNIQUE,
    usrPassword TEXT
  )
  ''';

  final String blockedUsersTable = '''
  CREATE TABLE blocked_users (
    blockId INTEGER PRIMARY KEY AUTOINCREMENT,
    usrName TEXT
  )
  ''';

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(userTable);
        await db.execute(blockedUsersTable);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(blockedUsersTable);
        }
      },
    );
  }

  Future<int> createUser(Users usr) async {
    try {
      final Database db = await initDB();
      return await db.insert("users", usr.toMap());
    } catch (e) {
      print("Error al registrar usuario: $e");
      return -1;
    }
  }

  Future<Users?> getUser(String usrName) async {
    final Database db = await initDB();
    final res = await db.query("users", where: "usrName = ?", whereArgs: [usrName]);
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }

  Future<bool> authenticate(Users usr) async {
    final Database db = await initDB();
    final result = await db.rawQuery(
      "SELECT * FROM users WHERE usrName = ? AND usrPassword = ?",
      [usr.usrName, usr.usrPassword],
    );
    return result.isNotEmpty;
  }

  Future<int> blockUser(String usrName) async {
    try {
      final Database db = await initDB();
      final existingBlock = await db.query(
        "blocked_users",
        where: "usrName = ?",
        whereArgs: [usrName],
      );
      if (existingBlock.isNotEmpty) return 0;

      return await db.insert("blocked_users", {"usrName": usrName});
    } catch (e) {
      print("Error al bloquear usuario: $e");
      return -1;
    }
  }

  Future<int> unblockUser(String usrName) async {
    try {
      final Database db = await initDB();
      return await db.delete("blocked_users", where: "usrName = ?", whereArgs: [usrName]);
    } catch (e) {
      print("Error al desbloquear usuario: $e");
      return -1;
    }
  }

  Future<bool> isUserBlocked(String usrName) async {
    final Database db = await initDB();
    final result = await db.query(
      "blocked_users",
      where: "usrName = ?",
      whereArgs: [usrName],
    );
    return result.isNotEmpty;
  }
}