import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../modele/note.dart';

/// Point d'accès unique à la base SQLite locale (pattern singleton).
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'appnotes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            date TEXT NOT NULL,
            important INTEGER NOT NULL DEFAULT 0,
            done INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // ---------- Authentification ----------

  /// Retourne true si les identifiants correspondent à un compte existant.
  Future<bool> login(String username, String password) async {
    final db = await database;
    final match = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return match.isNotEmpty;
  }

  /// Crée un nouveau compte. Retourne false si le pseudo est déjà pris.
  Future<bool> register(String username, String password) async {
    final db = await database;
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (existing.isNotEmpty) return false;

    await db.insert('users', {'username': username, 'password': password});
    return true;
  }

  // ---------- CRUD Notes ----------

  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert('notes', note.toMap()..remove('id'));
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'date ASC');
    return rows.map(Note.fromMap).toList();
  }
}
