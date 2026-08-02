import 'package:local_ai_calorie_app/model/diary_entry.dart';
import 'package:local_ai_calorie_app/model/food.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  //Private constructor for Singleton pattern
  DatabaseHelper._internal();
  
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calorie_tracker.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        food_name TEXT,
        food_id INTEGER,
        calories REAL,
        grams REAL,
        carbs REAL,
        sugars REAL,
        fiber REAL,
        fat REAL,
        saturated_fat REAL,
        protein REAL
        foodCalories REAL,
        foodGrams REAL,
        foodCarbs REAL,
        foodSugars REAL,
        foodFiber REAL,
        foodFat REAL,
        foodSaturated_fat REAL,
        foodProtein REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories REAL,
        grams REAL,
        carbs REAL,
        sugars REAL,
        fiber REAL,
        fat REAL,
        saturated_fat REAL,
        protein REAL
      )
    ''');
  }

  Future<void> _onOpen(Database db) async {    
    await addColumnIfNotExists(db, "diary_entries", "foodCalories", "REAL");
    await addColumnIfNotExists(db, "diary_entries", "foodGrams", "REAL");
    await addColumnIfNotExists(db, "diary_entries", "foodCarbs", "REAL");
    await addColumnIfNotExists(db, "diary_entries", "foodSugars", "REAL");
    await addColumnIfNotExists(db, "diary_entries", "foodFiber", "REAL");
    await addColumnIfNotExists(db, "diary_entries", "foodFat", "REAL");
    await addColumnIfNotExists(db, "diary_entries", "foodSaturated_fat", "REAL");
    await addColumnIfNotExists(db, "diary_entries", "foodProtein", "REAL");
  }

  Future<bool> addColumnIfNotExists(Database db, String tableName, String columnName, String columnType) async {
    
    final List<Map<String, Object?>> columns = await db.rawQuery("PRAGMA table_info('$tableName')");
    final bool exists = columns.any((col) => col['name']?.toString().toLowerCase() == columnName.toLowerCase());

    if (!exists) {
      await db.execute(
        "ALTER TABLE $tableName ADD COLUMN $columnName $columnType"
      );
      return true;
    }
    return false;
  } 

  Future<int> insertFood(Food food) async {
    final db = await database;
    return await db.insert('foods', food.toMap());
  }

  Future<void> updateFood(Food food) async {
    final db = await database;
    await db.update('foods', food.toMap(), where: "id = ${food.id}");
  }

  Future<List<Food>> getFoods() async {
    final db = await database;

    final rawList = await db.rawQuery('''
        SELECT 
        f.*,
        (
          SELECT date 
          FROM diary_entries 
          WHERE food_id = f.id 
          ORDER BY date DESC 
          LIMIT 1
        ) AS lastUsedAt,
        (
          SELECT grams 
          FROM diary_entries 
          WHERE food_id = f.id 
          ORDER BY date DESC 
          LIMIT 1
        ) AS lastUsedQuantity
      FROM foods f
      ORDER BY lastUsedAt DESC NULLS LAST, f.name ASC;
      ''');

    return rawList.map((json) => Food.fromMap(json)).toList();

    // final maps = await db.query(
    //   'foods',
    // );
    // return maps.map((map) => Food.fromMap(map)).toList();
  }

  Future<void> deleteFood(Food food) async {
    final db = await database;
    await db.delete('foods', where: "id = ${food.id}");
  }

  Future<int> insertEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert('diary_entries', entry.toMap());
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    final db = await database;
    await db.delete('diary_entries', where: "id = ${entry.id}");
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    final db = await database;
    await db.update('diary_entries', entry.toMap(), where: "id = ${entry.id}");
  }

  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final maps = await db.query(
      'diary_entries',
      where: 'date like ?',
      whereArgs: ['$dateStr%'],
    );

    return maps.map((map) => DiaryEntry.fromMap(map)).toList();
  }

  Future<List<DiaryEntry>> getEntriesByMealAndDate(DateTime date, MealType mealType) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final maps = await db.query(
      'diary_entries',
      where: 'date like ? and meal_type = ?',
      whereArgs: ['$dateStr%', mealType.name],
    );

    return maps.map((map) => DiaryEntry.fromMap(map)).toList();
  }
}