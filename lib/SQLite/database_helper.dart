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
    isActive INTEGER DEFAULT 0,
    profileImage TEXT
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

  final String contactsTable = '''
CREATE TABLE contacts (
  contactId INTEGER PRIMARY KEY AUTOINCREMENT,
  fullName TEXT NOT NULL,
  contactNumber TEXT NOT NULL
)
''';

  final String salesTable = '''
CREATE TABLE ventas (
  idventa INTEGER PRIMARY KEY AUTOINCREMENT,
  nombreCliente TEXT NOT NULL,
  numeroComprado INTEGER NOT NULL,
  precioComprado REAL NOT NULL,
  nota TEXT
)
''';


  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 5, // Incrementamos la versión para la nueva columna "profileImage"
      onCreate: (db, version) async {
        await db.execute(userTable);
        await db.execute(blockedUsersTable);
        await db.execute(verificationCodesTable);
        await db.execute(contactsTable); // Crear la tabla de contactos
        await db.execute(salesTable); // Crear la tabla de ventas
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          // Comprobar si la columna 'profileImage' ya existe
          await db.execute("CREATE TABLE IF NOT EXISTS contacts (contactId INTEGER PRIMARY KEY AUTOINCREMENT, fullName TEXT NOT NULL, contactNumber TEXT NOT NULL);");
          final tableInfo = await db.rawQuery("PRAGMA table_info(users)");
          final hasColumn = tableInfo.any((column) =>
          column['name'] == 'profileImage');

          if (!hasColumn) {
            await db.execute("ALTER TABLE users ADD COLUMN profileImage TEXT;");
            await db.execute("CREATE TABLE IF NOT EXISTS sales (saleId INTEGER PRIMARY KEY AUTOINCREMENT, productName TEXT NOT NULL, totalPrice REAL NOT NULL);");
          }
        }
      },
    );
  }

  // Obtener todas las ventas
  Future<List<Map<String, dynamic>>> getAllVentas() async {
    final db = await initDB();
    return await db.query("ventas");
  }

// Agregar una nueva venta (ahora con nota opcional)
  Future<int> addSale(
      String nombreCliente,
      int numeroComprado,
      double precioComprado, {
        String nota = '',
      }) async {
    try {
      final db = await initDB();
      return await db.insert(
        "ventas",
        {
          "nombreCliente": nombreCliente,
          "numeroComprado": numeroComprado,
          "precioComprado": precioComprado,
          "nota": nota,                   // ← nueva columna
        },
      );
    } catch (e) {
      print("Error al registrar la venta: $e");
      return -1;
    }
  }

// Eliminar una venta
  Future<int> deleteSale(int idventa) async {
    try {
      final db = await initDB();
      return await db.delete(
        "ventas",
        where: "idventa = ?",
        whereArgs: [idventa],
      );
    } catch (e) {
      print("Error al eliminar la venta: $e");
      return -1;
    }
  }

// Actualizar una venta (ahora también nota)
  Future<int> updateSale(
      int idventa,
      String nombreCliente,
      int numeroComprado,
      double precioComprado,
      String nota,
      ) async {
    try {
      final db = await initDB();
      return await db.update(
        "ventas",
        {
          "nombreCliente": nombreCliente,
          "numeroComprado": numeroComprado,
          "precioComprado": precioComprado,
          "nota": nota,                   // ← incluir nota
        },
        where: "idventa = ?",
        whereArgs: [idventa],
      );
    } catch (e) {
      print("Error al actualizar la venta: $e");
      return -1;
    }
  }

// Obtener una venta por su ID (incluye nota)
  Future<Map<String, dynamic>?> getVentaById(int idventa) async {
    final db = await initDB();
    final res = await db.query(
      "ventas",
      where: "idventa = ?",
      whereArgs: [idventa],
    );
    return res.isNotEmpty ? res.first : null;
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
      where: "usrName = ? OR email = ?",
      whereArgs: [usrName, usrName],
    );
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }

  Future<bool> authenticate(Users usr) async {
    final Database db = await initDB();
    final result = await db.rawQuery(
      "SELECT * FROM users WHERE (usrName = ? OR email = ?) AND usrPassword = ?",
      [usr.usrName, usr.usrName, usr.usrPassword],
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
  Future<void> updateProfileImage(String usrName, String imagePath) async {
    try {
      final Database db = await initDB();
      await db.update(
        'users',
        {'profileImage': imagePath}, // Guarda la ruta de la imagen
        where: 'usrName = ?',
        whereArgs: [usrName],
      );
    } catch (e) {
      print('Error al actualizar la imagen de perfil: $e');
    }
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
  Future<int> addContact(String fullName, String contactNumber) async {
    try {
      final Database db = await initDB();
      return await db.insert(
        "contacts",
        {
          "fullName": fullName,
          "contactNumber": contactNumber,
        },
      );
    } catch (e) {
      print("Error al registrar el contacto: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAllContacts() async {
    final db = await initDB();
    return await db.query("contacts");
  }

  Future<int> deleteContact(int contactId) async {
    try {
      final Database db = await initDB();
      return await db.delete(
        "contacts",
        where: "contactId = ?",
        whereArgs: [contactId],
      );
    } catch (e) {
      print("Error al eliminar el contacto: $e");
      return -1;
    }
  }

  Future<int> updateContact(int contactId, String fullName, String contactNumber) async {
    try {
      final Database db = await initDB();
      return await db.update(
        "contacts",
        {
          "fullName": fullName,
          "contactNumber": contactNumber,
        },
        where: "contactId = ?",
        whereArgs: [contactId],
      );
    } catch (e) {
      print("Error al actualizar el contacto: $e");
      return -1;
    }
  }

  Future<void> deleteDatabaseFile(String databaseName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    await deleteDatabase(path);
    print("Base de datos eliminada exitosamente: $path");
  }


  Future<List<Map<String, dynamic>>> getWinnersByNumber(String number) async {
    final db = await initDB();
    return await db.query(
      "ventas",
      where: "numeroComprado = ?",
      whereArgs: [number],
        orderBy: "precioComprado DESC",
    );
  }


  Future<int> deleteAllVentas() async {
    final db = await initDB();
    return await db.delete('ventas');
  }
}


