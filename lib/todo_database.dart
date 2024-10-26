import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class TodoDatabase {
  static final TodoDatabase instance = TodoDatabase._init();
  static Database? _database;

  TodoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE todos (
      id $idType,
      title $textType
    )
    ''');
  }

  Future<int> insertTodo(String title) async {
    final db = await instance.database;
    return await db.insert('todos', {'title': title});
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    final db = await instance.database;
    return await db.query('todos');
  }

  Future<int> deleteTodoById(int id) async {
    final db = await instance.database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}





