import 'package:assignment3/models/database_model.dart';
import 'package:assignment3/models/meal_planner.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'database_model.dart';

// Database helper class
class DatabaseHelper {
  static late DatabaseHelper _instance;
  static Database? _database;
  final String foodTable = 'Food';
  final String mealPlanTable = 'MealPlan';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Setup the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'calories_db.db');
    Database db = await openDatabase(
      path,
      version: 7,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $foodTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            calories INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $mealPlanTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            food_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            FOREIGN KEY (food_id) REFERENCES $foodTable(id)
          )
        ''');

        await _insertInitialFoodItems(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {},
    );
    return db;
  }

  // Function to insert the preferred food items
  Future<void> _insertInitialFoodItems(Database db) async {
    final foodItems = [
      {'name': 'Strawberries', 'calories': 50},
      {'name': 'Pineapple', 'calories': 82},
      {'name': 'Watermelon', 'calories': 30},
      {'name': 'Kiwi', 'calories': 61},
      {'name': 'Asparagus', 'calories': 20},
      {'name': 'Zucchini', 'calories': 33},
      {'name': 'Turkey Breast (cooked)', 'calories': 135},
      {'name': 'Shrimp (cooked)', 'calories': 99},
      {'name': 'Quinoa Salad', 'calories': 180},
      {'name': 'Whole Wheat Pasta (cooked)', 'calories': 174},
      {'name': 'Blueberries', 'calories': 84},
      {'name': 'Cottage Cheese', 'calories': 120},
      {'name': 'Walnuts', 'calories': 185},
      {'name': 'Kiwi', 'calories': 61},
      {'name': 'Peach', 'calories': 59},
      {'name': 'Pumpkin Seeds', 'calories': 126},
      {'name': 'Lemon', 'calories': 17},
      {'name': 'Cauliflower (cooked)', 'calories': 55},
      {'name': 'Feta Cheese', 'calories': 99},
      {'name': 'Soy Milk', 'calories': 80},
      {'name': 'White Chocolate', 'calories': 160},
      {'name': 'Quinoa Porridge', 'calories': 220},
      {'name': 'Cashew Butter', 'calories': 94},
      {'name': 'Ground Turkey (cooked)', 'calories': 220},
      {'name': 'Red Pepper', 'calories': 31},
      {'name': 'Arugula', 'calories': 5},
      {'name': 'Radish', 'calories': 12},
      {'name': 'Olive Tapenade', 'calories': 60},
      {'name': 'Multigrain Bread', 'calories': 80},
      {'name': 'Mango', 'calories': 60},
      {'name': 'Pomegranate', 'calories': 83},
      {'name': 'Cantaloupe', 'calories': 34},
      {'name': 'Cherry Tomatoes', 'calories': 18},
      {'name': 'Kale', 'calories': 33},
      {'name': 'Cabbage', 'calories': 22},
      {'name': 'Chicken Thigh (cooked)', 'calories': 180},
      {'name': 'Salmon Salad', 'calories': 210},
      {'name': 'Brown Rice (cooked)', 'calories': 215},
      {'name': 'Spaghetti Squash (cooked)', 'calories': 31},
      {'name': 'Blackberries', 'calories': 62},
      {'name': 'Yogurt Parfait', 'calories': 150},
      {'name': 'Pistachios', 'calories': 160},
      {'name': 'Grapfruit', 'calories': 52},
      {'name': 'Pear', 'calories': 57},
      {'name': 'Sunflower Seeds', 'calories': 120},
      {'name': 'Lime', 'calories': 20},
      {'name': 'Steamed Broccoli', 'calories': 55},
      {'name': 'Goat Cheese', 'calories': 103},
      {'name': 'Almond Milk', 'calories': 60},
      {'name': 'Dark Chocolate Bar', 'calories': 180},
      {'name': 'Chia Pudding', 'calories': 150},
      {'name': 'Hazelnut Butter', 'calories': 100},
      {'name': 'Lean Beef (cooked)', 'calories': 250},
      {'name': 'Yellow Pepper', 'calories': 27},
      {'name': 'Mixed Greens', 'calories': 10},
      {'name': 'Cucumber', 'calories': 16},
      {'name': 'Artichoke Hearts', 'calories': 50},
      {'name': 'Whole Grain Bread', 'calories': 70},
    ];

    for (final foodItem in foodItems) {
      await db.insert(
        'Food',
        foodItem,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Function to get all the food items
  Future<List<Food>> getAllFoods() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(foodTable);
    return result.map((map) => Food.fromMap(map)).toList();
  }

  // Function to create a meal plan
  Future<int> createMealPlan(int foodId, String date) async {
    Database db = await database;
    return await db.insert(mealPlanTable, {'food_id': foodId, 'date': date});
  }

  // Function to remove all the food items for a particular date, in essence
  // it removes the meal plan for that date.
  Future<void> clearMealPlan(String date) async {
    Database db = await database;

    await db.delete(
      mealPlanTable,
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // Function to delete a particular food item
  Future<int> deleteMealPlan(int mealPlanId) async {
    Database db = await database;
    return await db.delete(
      mealPlanTable,
      where: 'id = ?',
      whereArgs: [mealPlanId],
    );
  }

  // Function to get the meal plan for a particular date
  Future<List<Map<String, dynamic>>> getMealPlanByDate(String date) async {
    Database db = await database;
    return await db.rawQuery('''
    SELECT $mealPlanTable.id, $mealPlanTable.food_id, $mealPlanTable.date,
           $foodTable.name AS food_name, $foodTable.calories AS food_calories
    FROM $mealPlanTable
    INNER JOIN $foodTable ON $mealPlanTable.food_id = $foodTable.id
    WHERE $mealPlanTable.date = ?
  ''', [date]);
  }
}