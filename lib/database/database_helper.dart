import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/chat_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  void _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT,
        content TEXT
      )
    ''');
  }

  Future<int> insertMessage(Message message) async {
    Database db = await instance.database;
    return await db.insert('chat_messages', message.toJson());
  }

  Future<int> insertUserMessage(Message message) async {
    Database db = await instance.database;
    return await db.insert('chat_messages', message.toJson());
  }

  Future<List<Message>> getMessages() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('chat_messages');
    return maps.map((json) => Message.fromJson(json)).toList();
  }

  Future<int> deleteAllMessages() async {
    Database db = await instance.database;
    return await db.delete('chat_messages');
  }
}
