// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// // 1. IMPOR MODEL TRANSAKSI (sudah ada)
// import 'package:budgetin_app/models/transaction_model.dart';
// // 2. IMPOR MODEL WISH BARU
// import 'package:budgetin_app/models/wish_model.dart'; // Pastikan path benar
//
// class DatabaseHelper {
//   // Variabel yang sudah ada (Singleton Instance)
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Database? _database;
//
//   // Nama tabel yang sudah ada
//   static const String tableTransactions = 'transactions';
//   // NAMA TABEL BARU UNTUK WISHES
//   static const String tableWishes = 'wishes';
//
//   DatabaseHelper._init();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB("transaction.db");
//     return _database!;
//   }
//
//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);
//
//     return await openDatabase(
//       path,
//       version: 2, // NAIKKAN VERSI DARI 1 KE 2 UNTUK MENAMBAHKAN TABEL BARU
//       onCreate: _createDB,
//       onUpgrade: _upgradeDB, // TAMBAHKAN onUpgrade UNTUK HANDLE UPGRADE
//     );
//   }
//
//   Future _createDB(Database db, int version) async {
//     // Tabel transaksi (sudah ada)
//     await db.execute('''
//       CREATE TABLE $tableTransactions (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         type TEXT,
//         category TEXT,
//         amount REAL,
//         date TEXT,
//         note TEXT
//       )
//     ''');
//
//     // TAMBAHKAN TABEL WISHES BARU
//     await db.execute('''
//       CREATE TABLE $tableWishes (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         amount REAL NOT NULL,
//         dateTarget TEXT NOT NULL,
//         color TEXT NOT NULL,
//         imagePath TEXT
//       )
//     ''');
//   }
//
//   // TAMBAHKAN FUNGSI onUpgrade UNTUK MENANGANI VERSI BARU
//   Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
//     if (oldVersion < 2) {
//       // Jika upgrade dari versi 1 ke 2, buat tabel wishes
//       await db.execute('''
//         CREATE TABLE $tableWishes (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           name TEXT NOT NULL,
//           amount REAL NOT NULL,
//           dateTarget TEXT NOT NULL,
//           color TEXT NOT NULL,
//           imagePath TEXT
//         )
//       ''');
//     }
//     // Tambahkan logika upgrade lainnya jika versi lebih tinggi
//   }
//
//   // Fungsi untuk transaksi (sudah ada, tidak diubah)
//   Future<int> insertTransaction(Map<String, dynamic> data) async {
//     // PERBAIKAN: Tambah validasi sederhana
//     if (data['amount'] == null || (data['amount'] is num && data['amount'] <= 0)) {
//       throw Exception('Amount must be greater than 0');
//     }
//     final db = await instance.database;
//     return await db.insert(tableTransactions, data, conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//   Future<List<Map<String, dynamic>>> getTransactionsMap() async {
//     final db = await instance.database;
//     return await db.query(tableTransactions, orderBy: "date DESC, id DESC");
//   }
//
//   Future<List<TransactionModel>> getTransactions() async {
//     final db = await instance.database;
//     final List<Map<String, dynamic>> maps = await db.query(tableTransactions, orderBy: "date DESC, id DESC");
//     if (maps.isEmpty) {
//       return [];
//     } else {
//       return maps.map((transactionMap) => TransactionModel.fromMap(transactionMap)).toList();
//     }
//   }
//
//   Future<int> deleteTransaction(int id) async {
//     final db = await instance.database;
//     return await db.delete(tableTransactions, where: 'id = ?', whereArgs: [id]);
//   }
//
//   // FUNGSI BARU UNTUK WISHES (MIRIP DENGAN TRANSAKSI)
//   Future<int> insertWish(WishModel wish) async {
//     // PERBAIKAN: Tambah validasi sederhana
//     if (wish.amount <= 0) {
//       throw Exception('Wish amount must be greater than 0');
//     }
//     final db = await instance.database;
//     return await db.insert(tableWishes, wish.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//   Future<List<WishModel>> getWishes() async {
//     final db = await instance.database;
//     final List<Map<String, dynamic>> maps = await db.query(tableWishes, orderBy: "dateTarget DESC, id DESC");
//     if (maps.isEmpty) {
//       return [];
//     } else {
//       return maps.map((wishMap) => WishModel.fromMap(wishMap)).toList();
//     }
//   }
//
//   Future<int> updateWish(WishModel wish) async {
//     final db = await instance.database;
//     return await db.update(
//       tableWishes,
//       wish.toMap(),
//       where: 'id = ?',
//       whereArgs: [wish.id],
//     );
//   }
//
//   Future<int> deleteWish(int id) async {
//     final db = await instance.database;
//     return await db.delete(tableWishes, where: 'id = ?', whereArgs: [id]);
//   }
// }