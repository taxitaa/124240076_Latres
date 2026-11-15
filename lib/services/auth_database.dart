import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AuthDatabase {
  AuthDatabase._();

  static final AuthDatabase instance = AuthDatabase._();
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      path.join(databasePath, 'multiverse_users.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final db = await _db;
    final normalizedEmail = email.trim().toLowerCase();
    final existing = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) return false;

    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final saltHex = salt.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    await db.insert('users', {
      'username': username.trim(),
      'email': normalizedEmail,
      'password_hash': _hashPassword(password, saltHex),
      'password_salt': saltHex,
    });
    return true;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final db = await _db;
    final users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (users.isEmpty) return null;

    final user = users.first;
    final salt = user['password_salt']! as String;
    if (_hashPassword(password, salt) != user['password_hash']) return null;
    return user['username']! as String;
  }

  String _hashPassword(String password, String salt) {
    var digest = sha256.convert(utf8.encode('$salt:$password')).bytes;
    for (var round = 0; round < 10000; round++) {
      digest = sha256.convert([...digest, ...utf8.encode(salt)]).bytes;
    }
    return digest.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
