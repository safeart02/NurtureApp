import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class DBHelper {
  static const String _databaseName = "plants.db";
  static const int _databaseVersion = 1;
  static const String tableName = "crops";

  static Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }

  static Future<Database> initializeDatabase() async {
    final dbPath = await getDatabasePath();

    if (!await File(dbPath).exists()) {
      try {
        final byteData = await rootBundle.load('assets/db/$_databaseName');
        final buffer = byteData.buffer.asUint8List();

        await File(dbPath).writeAsBytes(buffer, flush: true);
      } catch (e) {
        print("Error loading preloaded database: $e");
        return _createDatabase(dbPath);
      }
    }

    final db = await openDatabase(dbPath);
    await _insertDefaultCropsIfNeeded(db);
    return db;
  }

  static Future<Database> _createDatabase(String dbPath) async {
    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            description TEXT NOT NULL,
            image_path TEXT NOT NULL,
            nitrogen TEXT NOT NULL CHECK (nitrogen IN ('HIGH', 'MEDIUM', 'LOW')),
            phosphorous TEXT NOT NULL CHECK (phosphorous IN ('HIGH', 'MEDIUM', 'LOW')),
            potassium TEXT NOT NULL CHECK (potassium IN ('HIGH', 'MEDIUM', 'LOW')),
            ph REAL NOT NULL CHECK(ph >= 0 AND ph <= 14),
            status TEXT NOT NULL
          )
        ''');

        await _insertDefaultCropsIfNeeded(db);
      },
    );
  }

  static Future<void> _insertDefaultCropsIfNeeded(Database db) async {
    final List<Map<String, dynamic>> crops = await db.query(tableName);

    if (crops.isEmpty) {
      final defaultCrops = [
        {
          'name': 'Banana',
          'description': 'Elongated and curved, with a smooth yellow peel that darkens as it ripens.',
          'image_path': 'assets/images/Crops/banana.png',
          'nitrogen': 'HIGH',
          'phosphorous': 'HIGH',
          'potassium': 'HIGH',
          'ph': 7.5,
          'status' : 'ACTIVE',
        },
        {
          'name': 'Okra',
          'description': 'Long, tapered green pods with ridges, growing upright on tall plants, usually around 3 to 5 inches long.',
          'image_path': 'assets/images/Crops/okra.png',
          'nitrogen': 'HIGH',
          'phosphorous': 'HIGH',
          'potassium': 'MEDIUM',
          'ph': 8.0,
          'status' : 'ACTIVE',
        },
        {
          'name': 'Cucumber',
          'description': 'Cylindrical and green, often with a bumpy texture, typically measuring 6 to 9 inches in length.',
          'image_path': 'assets/images/Crops/cucumber.png',
          'nitrogen': 'MEDIUM',
          'phosphorous': 'HIGH',
          'potassium': 'HIGH',
          'ph': 8.0,
          'status' : 'ACTIVE',
        },
        {
          'name': 'Sweet Potato',
          'description': 'Tapered, rough reddish-brown skin with a creamy interior, typically varying in size and shape.',
          'image_path': 'assets/images/Crops/sweetpotato.png',
          'nitrogen': 'MEDIUM',
          'phosphorous': 'HIGH',
          'potassium': 'HIGH',
          'ph': 7.0,
          'status' : 'ACTIVE',
        },
        {
          'name': 'Talong',
          'description': 'Glossy, dark purple, oval-shaped fruit with a smooth skin and a green calyx at the top.',
          'image_path': 'assets/images/Crops/talong.png',
          'nitrogen': 'HIGH',
          'phosphorous': 'MEDIUM',
          'potassium': 'MEDIUM',
          'ph': 6.7,
          'status' : 'ACTIVE',
        },
      ];

      for (var crop in defaultCrops) {
        await db.insert(tableName, crop);
      }
    }
  }

  static Future<bool> cropNameExists(String name) async {
  final db = await initializeDatabase();
  final result = await db.query(
    tableName,
    where: 'name = ?',
    whereArgs: [name],
  );
  return result.isNotEmpty;
}


  static Future<int> insertCrop(Map<String, dynamic> crop) async {
    final db = await initializeDatabase();
    try {
      return await db.insert(tableName, crop);
    } catch (e) {
      print("Error inserting crop: $e");
      throw Exception("Failed to insert crop. Ensure the name is unique and data is valid.");
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCrops() async {
  final db = await initializeDatabase();
  try {
    return await db.query(
      tableName,
      orderBy: "name ASC",
      where: "status = ?",
      whereArgs: ["ACTIVE"],
    );
  } catch (e) {
    print("Error fetching crops: $e");
    throw Exception("Failed to fetch crops from the database.");
  }
}


static Future<List<Map<String, dynamic>>> fetchArchivedCrops() async {
  final db = await initializeDatabase();
  try {
    return await db.query(
      tableName,
      orderBy: "name ASC",
      where: "status = ?",
      whereArgs: ["INACTIVE"],
    );
  } catch (e) {
    print("Error fetching archived crops: $e");
    throw Exception("Failed to fetch archived crops from the database.");
  }
}

  static Future<int> updateCrop(Map<String, dynamic> crop) async {
    final db = await initializeDatabase();
    try {
      return await db.update(
        tableName,
        crop,
        where: "id = ?",
        whereArgs: [crop['id']],
      );
    } catch (e) {
      print("Error updating crop: $e");
      throw Exception("Failed to update crop data.");
    }
  }

  static Future<int> archiveCrop(int cropId) async {
  final db = await initializeDatabase();
  try {
    return await db.update(
      tableName,
      {'status': 'INACTIVE'},
      where: "id = ?",
      whereArgs: [cropId],
    );
  } catch (e) {
    print("Error updating crop: $e");
    throw Exception("Failed to update crop data.");
  }
}

static Future<int> unarchiveCrop(int cropId) async {
  final db = await initializeDatabase();
  try {
    return await db.update(
      tableName,
      {'status': 'ACTIVE'}, 
      where: "id = ?",
      whereArgs: [cropId],
    );
  } catch (e) {
    print("Error updating crop: $e");
    throw Exception("Failed to update crop data.");
  }
}

  static Future<bool> checkDatabaseExists() async {
    final dbPath = await getDatabasePath();
    return await File(dbPath).exists();
  }

  static Future<void> downloadDatabaseToDownloads() async {
    try {
      final dbPath = await getDatabasePath();
      final file = File(dbPath);

      final downloadsDirectory = await getExternalStorageDirectory();
      if (downloadsDirectory == null) {
        throw Exception("Unable to get Downloads directory.");
      }

      final downloadPath = join(downloadsDirectory.path, 'plants.db');
      await file.copy(downloadPath);

      print("Database downloaded to Downloads folder.");
    } catch (e) {
      print("Error downloading database: $e");
      throw Exception("Failed to download database.");
    }
  }

  static Future<void> overwriteDatabaseWithNewFile(String newDatabasePath) async {
    final dbPath = await getDatabasePath();
    final db = await openDatabase(dbPath);

    if (await _isDatabaseValid(newDatabasePath)) {
      await db.close();
      await File(newDatabasePath).copy(dbPath);
      print("Database overwritten successfully.");
    } else {
      print("New database schema is invalid.");
      throw Exception("Invalid database schema.");
    }
  }

  static Future<bool> _isDatabaseValid(String dbPath) async {
    try {
      final db = await openDatabase(dbPath);
      var result = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table" AND name="$tableName"');
      if (result.isEmpty) {
        print("Table '$tableName' does not exist.");
        return false;
      }
      return true;
    } catch (e) {
      print("Error validating database schema: $e");
      return false;
    }
  }

  static Future<void> executeSQL(String query) async {
    final db = await initializeDatabase();
    try {
      await db.execute(query);
    } catch (e) {
      print("Error executing SQL query: $e");
      throw Exception("Failed to execute query: $query");
    }
  }


}
