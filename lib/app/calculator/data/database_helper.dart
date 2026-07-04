import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/history_item.dart';

/// SQLite database helper untuk menyimpan riwayat perhitungan secara permanen.
/// Riwayat tidak akan hilang meski aplikasi ditutup atau di-restart.
class DatabaseHelper {
  static const _dbName = 'calculator_2026.db';
  static const _dbVersion = 1;
  static const _tableHistory = 'history';

  static DatabaseHelper? _instance;
  Database? _db;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableHistory (
            id TEXT PRIMARY KEY,
            calculation TEXT NOT NULL,
            result TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  /// Menyimpan item riwayat baru ke database.
  Future<void> insertHistory(HistoryItem item) async {
    final db = await database;
    await db.insert(
      _tableHistory,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mengambil semua riwayat, diurutkan dari yang terbaru.
  Future<List<HistoryItem>> fetchAllHistory({int limit = 200}) async {
    final db = await database;
    final maps = await db.query(
      _tableHistory,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((m) => HistoryItem.fromMap(m)).toList();
  }

  /// Menghapus semua riwayat.
  Future<void> deleteAllHistory() async {
    final db = await database;
    await db.delete(_tableHistory);
  }

  /// Menghapus satu item riwayat berdasarkan id.
  Future<void> deleteHistoryById(String id) async {
    final db = await database;
    await db.delete(_tableHistory, where: 'id = ?', whereArgs: [id]);
  }

  /// Menutup koneksi database.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
