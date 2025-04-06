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
    usrPassword TEXT,
    isActive INTEGER DEFAULT 0
  )
  ''';

  final String blockedUsersTable = '''
  CREATE TABLE blocked_users (
    blockId INTEGER PRIMARY KEY AUTOINCREMENT,
    usrName TEXT
  )
  ''';

  final String verificationCodesTable = '''
  CREATE TABLE verification_codes (
    email TEXT PRIMARY KEY,
    code TEXT,
    created_at TEXT
  )
  ''';

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute(userTable);
        await db.execute(blockedUsersTable);
        await db.execute(verificationCodesTable);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute(verificationCodesTable);
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
    final res = await db.query(
      "users",
      where: "usrName = ?",
      whereArgs: [usrName],
    );
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

  Future<void> updateConnectionStatus(String usrName, bool isActive) async {
    try {
      final Database db = await initDB();
      await db.update(
        'users',
        {'isActive': isActive ? 1 : 0},
        where: 'usrName = ?',
        whereArgs: [usrName],
      );
    } catch (e) {
      print('Error al actualizar el estado de conexión: $e');
    }
  }

  Future<List<Users>> getAllUsers() async {
    final db = await initDB();
    final List<Map<String, dynamic>> result = await db.query('users');
    return result.map((user) => Users.fromMap(user)).toList();
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
      return await db.delete(
        "blocked_users",
        where: "usrName = ?",
        whereArgs: [usrName],
      );
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

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final Database db = await initDB();
      final user = await db.query(
        "users",
        where: "email = ?",
        whereArgs: [email],
      );

      if (user.isNotEmpty) {
        await db.update(
          "users",
          {"usrPassword": newPassword},
          where: "email = ?",
          whereArgs: [email],
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error al restablecer la contraseña: $e");
      return false;
    }
  }

  Future<bool> changePassword(
      String usrName, String currentPassword, String newPassword) async {
    try {
      final Database db = await initDB();

      final List<Map<String, dynamic>> userQuery = await db.query(
        "users",
        where: "usrName = ? AND usrPassword = ?",
        whereArgs: [usrName, currentPassword],
      );

      if (userQuery.isNotEmpty) {
        final int rowsAffected = await db.update(
          "users",
          {"usrPassword": newPassword},
          where: "usrName = ?",
          whereArgs: [usrName],
        );

        return rowsAffected > 0;
      }

      return false;
    } catch (e) {
      print("Error al cambiar la contraseña: $e");
      return false;
    }
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    try {
      final Database db = await initDB();
      int rowsAffected = await db.update(
        'users',
        {'usrPassword': newPassword},
        where: 'email = ?',
        whereArgs: [email],
      );

      return rowsAffected > 0;
    } catch (e) {
      print('Error al actualizar la contraseña: $e');
      return false;
    }
  }

  Future<String?> getVerificationCode(String email) async {
    final Database db = await initDB();

    final result = await db.query(
      'verification_codes',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first['code'] as String;
    }
    return null;
  }

  Future<void> storeVerificationCode(String email, String code) async {
    final Database db = await initDB();

    await db.insert(
      'verification_codes',
      {
        'email': email,
        'code': code,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteVerificationCode(String email) async {
    final Database db = await initDB();

    await db.delete(
      'verification_codes',
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<bool> verifyCode(String email, String enteredCode) async {
    final storedCode = await getVerificationCode(email);

    if (storedCode != null && storedCode == enteredCode) {
      await deleteVerificationCode(email);
      return true;
    }
    return false;
  }

  Future<bool> deleteUserAccount(String email) async {
    try {
      final db = await initDB();
      int rowsDeleted = await db.delete(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return rowsDeleted > 0;
    } catch (e) {
      print("Error al eliminar el usuario: $e");
      return false;
    }
  }

  Future<bool> updateEmail(String currentEmail, String newEmail) async {
    try {
      final db = await initDB();
      int rowsAffected = await db.update(
        'users',
        {'email': newEmail},
        where: 'email = ?',
        whereArgs: [currentEmail],
      );
      return rowsAffected > 0;
    } catch (e) {
      print('Error al actualizar el correo: $e');
      return false;
    }
  }

  Future<bool> isEmailTaken(String email) async {
    try {
      final db = await initDB();
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error al verificar el correo: $e');
      return false;
    }
  }
}