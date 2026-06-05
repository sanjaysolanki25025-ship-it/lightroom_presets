import 'package:lightroom_template/data/models/favourite_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();

  factory DbHelper() => _instance;

  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("present.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favourite(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            image TEXT,
            category TEXT,
            presentId TEXT,
            coin TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertFavourite(FavouriteModel favourite) async {
    final db = await database;
    return await db.insert("favourite", favourite.toMap());
  }

  /// get data by presentId
  Future<FavouriteModel> fetchDataBypresentId(String presentId) async {
    final db = await database;
    final result = await db.query("favourite", where: "presentId = ?", whereArgs: [presentId]);
    return FavouriteModel.fromMap(result.first);
  }

  /// delete by presentId
  Future<int> deleteBypresentId(String presentId) async {
    final db = await database;
    return await db.delete("favourite", where: "presentId = ?", whereArgs: [presentId]);
  }

  /// get all favourites
  Future<List<FavouriteModel>> getFavourites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("favourite");
    return List.generate(maps.length, (i) {
      return FavouriteModel.fromMap(maps[i]);
    });
  }

  /// delete all data
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('favourite');
  }
}
