import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'favorites.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE favorites(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER UNIQUE
        )
      ''');
    });
  }

  Future<void> toggleFavorite(int productId) async {
    final db = await database;
    if (await isFavorite(productId)) {
      await db.delete('favorites', where: 'productId = ?', whereArgs: [productId]);
    } else {
      await db.insert('favorites', {'productId': productId}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<bool> isFavorite(int productId) async {
    final db = await database;
    final maps = await db.query('favorites', where: 'productId = ?', whereArgs: [productId]);
    return maps.isNotEmpty;
  }

  Future<List<int>> getFavoriteProductIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return maps[i]['productId'] as int;
    });
  }
}
