import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/bird.dart';

class DatabaseService {
  static const _databaseName = "birdsong_trainer.db";
  static const _databaseVersion = 1;

  // Singleton instance
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._internal();
  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE birds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        species_code TEXT UNIQUE NOT NULL,
        common_name TEXT NOT NULL,
        scientific_name TEXT NOT NULL,
        family TEXT,
        region TEXT,
        difficulty INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE bird_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        is_custom INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE bird_list_items (
        list_id INTEGER,
        bird_id INTEGER,
        FOREIGN KEY (list_id) REFERENCES bird_lists (id),
        FOREIGN KEY (bird_id) REFERENCES birds (id),
        PRIMARY KEY (list_id, bird_id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Bird operations
  Future<int> insertBird(Bird bird) async {
    final db = await database;
    return await db.insert(
      'birds',
      {
        'species_code': bird.speciesCode,
        'common_name': bird.commonName,
        'scientific_name': bird.scientificName,
        'family': bird.family,
        'region': bird.region,
        'difficulty': bird.difficulty,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Bird>> getBirds({
    String? region,
    String? family,
    int? maxDifficulty,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'birds',
      where: region != null || family != null || maxDifficulty != null
          ? '${region != null ? 'region = ?' : ''} ${family != null ? 'AND family = ?' : ''} ${maxDifficulty != null ? 'AND difficulty <= ?' : ''}'
          : null,
      whereArgs: [
        if (region != null) region,
        if (family != null) family,
        if (maxDifficulty != null) maxDifficulty,
      ].where((e) => e != null).toList(),
    );

    return List.generate(maps.length, (i) {
      return Bird(
        speciesCode: maps[i]['species_code'],
        commonName: maps[i]['common_name'],
        scientificName: maps[i]['scientific_name'],
        family: maps[i]['family'],
        region: maps[i]['region'],
        difficulty: maps[i]['difficulty'],
      );
    });
  }

  // Bird list operations
  Future<int> createBirdList(String name, String description,
      {bool isCustom = false}) async {
    final db = await database;
    return await db.insert(
      'bird_lists',
      {
        'name': name,
        'description': description,
        'is_custom': isCustom ? 1 : 0,
      },
    );
  }

  Future<void> addBirdToList(int listId, int birdId) async {
    final db = await database;
    await db.insert(
      'bird_list_items',
      {
        'list_id': listId,
        'bird_id': birdId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Bird>> getBirdsInList(int listId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.* FROM birds b
      INNER JOIN bird_list_items bli ON b.id = bli.bird_id
      WHERE bli.list_id = ?
    ''', [listId]);

    return List.generate(maps.length, (i) {
      return Bird(
        speciesCode: maps[i]['species_code'],
        commonName: maps[i]['common_name'],
        scientificName: maps[i]['scientific_name'],
        family: maps[i]['family'],
        region: maps[i]['region'],
        difficulty: maps[i]['difficulty'],
      );
    });
  }
}
