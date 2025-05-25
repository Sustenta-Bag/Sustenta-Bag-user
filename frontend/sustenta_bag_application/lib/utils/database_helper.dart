import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sustenta_bag1.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY,
        email TEXT,
        role TEXT,
        entityId INTEGER,
        active INTEGER,
        firebaseId TEXT,
        fcmToken TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE entity (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        cpf TEXT,
        phone TEXT,
        idAddress INTEGER,
        status TEXT,
        createdAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE auth_token (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // User operations
  Future<int> saveUser(Map<String, dynamic> user) async {
    Database db = await database;
    
    // Delete existing user data
    await db.delete('user');
    
    return await db.insert('user', {
      'id': user['id'],
      'email': user['email'],
      'role': user['role'],
      'entityId': user['entityId'],
      'active': user['active'] ? 1 : 0,
      'firebaseId': user['firebaseId'],
      'fcmToken': user['fcmToken'],
      'createdAt': user['createdAt'],
      'updatedAt': user['updatedAt'],
    });
  }

  // Entity operations
  Future<int> saveEntity(Map<String, dynamic> entity) async {
    Database db = await database;
    
    // Delete existing entity data
    await db.delete('entity');
    print(entity);
    
    return await db.insert('entity', {
      'id': entity['id'],
      'name': entity['name'],
      'email': entity['email'],
      'cpf': entity['cpf'],
      'phone': entity['phone'],
      'idAddress': entity['idAddress'],
      'status': entity['status'],
      'createdAt': entity['createdAt'],
    });
  }

  // Token operations
  Future<int> saveToken(String token) async {
    Database db = await database;
    
    // Delete existing tokens
    await db.delete('auth_token');
    
    return await db.insert('auth_token', {'token': token});
  }

  Future<String?> getToken() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('auth_token', limit: 1);
    if (result.isNotEmpty) {
      return result.first['token'];
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUser() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('user', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getEntity() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('entity', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete('user');
    await db.delete('entity');
    await db.delete('auth_token');
  }
}
