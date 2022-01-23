import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/model/todo.dart';
import 'package:todo/constants/db.dart';

class TodoDatabase {
  static final TodoDatabase instance = TodoDatabase._init();

  static Database? _database;

  TodoDatabase._init();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDB('todo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE $tableName (
  ${TaskFields.id} $idType,
  ${TaskFields.completed} $boolType,
  ${TaskFields.title} $textType,
  ${TaskFields.description} $textType,
  ${TaskFields.dueDate} $textType,
  ${TaskFields.priority} $intType
)
''');
  }

  Future<Task> create(Task task) async {
    final db = await instance.database;
    final id = await db!.insert(tableName, task.toJson());
    return task.copy(id: id);
  }

  Future<Task> readTask(int id) async {
    final db = await instance.database;

    final maps = await db!.query(
      tableName,
      columns: TaskFields.values,
      where: '${TaskFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromJson(maps.first);
    } else {
      throw Exception('Task ID NOT FOUND');
    }
  }

  Future<List<Task>> readAllTask() async {
    final db = await instance.database;
    const orderBy = '${TaskFields.priority} ASC';
    final result = await db!.query(tableName, orderBy: orderBy);
    // print(result.map((json) => Task.fromJson(json)).toList());
    return result.map((json) => Task.fromJson(json)).toList();
  }

  Future<int> update(Task task) async {
    print(task.toJson().toString());
    final db = await instance.database;
    return db!.update(
      tableName,
      task.toJson(),
      where: '${TaskFields.id} = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    if (id == -1) {
      return -1;
    }
    final db = await instance.database;
    return await db!.delete(
      tableName,
      where: '${TaskFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db!.close();
  }
}
