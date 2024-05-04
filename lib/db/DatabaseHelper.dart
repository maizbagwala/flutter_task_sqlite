import 'dart:io';
import 'package:flutter_task_sqlite/model/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'user';

  static const columnId = '_id';
  static const columnEmail = 'email';
  static const columnPassword = 'password';
  static const columnName = 'name';

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = documentsDirectory.path + _databaseName;
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY Autoincrement,
            $columnEmail TEXT NOT NULL,
            $columnName TEXT NOT NULL,
            $columnPassword TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(User user) async {
    Database db = await instance.database;
    return await db.insert(table, user.toMap());
  }

  Future<List<User>> queryAllRows() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> list = await db.query(table);
    List<User> userList = [];
    list.map((e) => userList.add(User.fromMap(e)));
    return userList;
  }

  Future<User> queryFirstRows(String email, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> list = await db.rawQuery(
        'SELECT * FROM $table WHERE $columnEmail = ? AND $columnPassword = ?',
        [email, password]);
    return User.fromMap(list.first);
  }

  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> update(User user) async {
    Database db = await instance.database;
    int id = user.id!;
    return await db
        .update(table, user.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
