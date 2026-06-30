import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'cycle_app.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS mood');
        await db.execute('DROP TABLE IF EXISTS menstruasi');
        await db.execute('DROP TABLE IF EXISTS users');
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE menstruasi (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        tanggal_mulai TEXT,
        tanggal_selesai TEXT,
        siklus_ke INTEGER,
        catatan TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE mood (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        tanggal TEXT,
        mood TEXT,
        catatan TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // ========== USER ==========

  Future<int> saveUserFromServer({
    required int id,
    required String username,
    required String password,
  }) async {
    var dbClient = await db;

    return await dbClient.insert(
      'users',
      {
        'id': id,
        'username': username,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> register(String username, String password) async {
    var dbClient = await db;

    return await dbClient.insert(
      'users',
      {
        'username': username,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    var dbClient = await db;

    var result = await dbClient.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return {
        'id': result[0]['id'],
        'username': result[0]['username'],
      };
    }

    return null;
  }

  Future<bool> isUsernameTaken(String username) async {
    var dbClient = await db;

    var result = await dbClient.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty;
  }

  // ========== MENSTRUASI ==========

  Future<int> insertMenstruasi(Map<String, dynamic> data) async {
    var dbClient = await db;

    return await dbClient.insert(
      'menstruasi',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMenstruasi(int userId) async {
    var dbClient = await db;

    return await dbClient.query(
      'menstruasi',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'tanggal_mulai DESC',
    );
  }

  Future<int> deleteMenstruasi(int id) async {
    var dbClient = await db;

    return await dbClient.delete(
      'menstruasi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateMenstruasi(Map<String, dynamic> data) async {
    var dbClient = await db;

    return await dbClient.update(
      'menstruasi',
      {
        'tanggal_mulai': data['tanggal_mulai'],
        'tanggal_selesai': data['tanggal_selesai'],
        'siklus_ke': data['siklus_ke'],
        'catatan': data['catatan'],
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [data['id'], data['user_id']],
    );
  }

  // ========== MOOD ==========

  Future<int> insertMood(Map<String, dynamic> data) async {
    var dbClient = await db;

    return await dbClient.insert(
      'mood',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMood(int userId) async {
    var dbClient = await db;

    return await dbClient.query(
      'mood',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'tanggal DESC',
    );
  }

  Future<int> deleteMood(int id) async {
    var dbClient = await db;

    return await dbClient.delete(
      'mood',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}