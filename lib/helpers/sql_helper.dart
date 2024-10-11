// helpers/sql_helper.dart
import 'package:alimento/models/alimento.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class SqlHelper {
  static final SqlHelper _instance = SqlHelper._internal();
  factory SqlHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  SqlHelper._internal();

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alimentos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alimentos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertAlimento(Alimento alimento) async {
    final db = await database;
    return await db.insert('alimentos', alimento.toMap());
  }

  Future<List<Alimento>> getAllAlimentos() async {
    final db = await database;
    final result = await db.query('alimentos');
    return result.map((json) => Alimento.fromMap(json)).toList();
  }

  Future<int> updateAlimento(Alimento alimento) async {
    final db = await database;
    return await db.update(
      'alimentos',
      alimento.toMap(),
      where: 'id = ?',
      whereArgs: [alimento.id],
    );
  }

  Future<int> deleteAlimento(int id) async {
    final db = await database;
    return await db.delete(
      'alimentos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
