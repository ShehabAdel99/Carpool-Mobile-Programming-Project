import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'users';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'driver_database.db');

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firebaseId TEXT,
            fullName TEXT,
            email TEXT,
            phoneNumber TEXT,
            password TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    try {
      final db = await database;
      return await db.insert(tableName, user);
    } catch (e) {
      print('Error inserting user: $e');
      return -1; // or another error code
    }
  }

  Future<Map<String, dynamic>?> getUserDetails(String firebaseUserId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        tableName,
        where: 'firebaseId = ?',
        whereArgs: [firebaseUserId],
      );

      if (results.isNotEmpty) {
        return results.first;
      } else {
        return null; // User with the specified Firebase ID not found
      }
    } catch (e) {
      print('Error getting user details: $e');
      return null; // or another error handling, you can throw an exception if needed
    }
  }
}
