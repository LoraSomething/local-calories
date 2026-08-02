
import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/food.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack
}

extension MealTypeX on MealType {
  /// The main brand/accent color for this meal type
  Color get color {
    switch (this) {
      case MealType.breakfast:
        return const Color.fromARGB(255, 192, 117, 4);
      case MealType.lunch:
        return const Color.fromARGB(255, 2, 164, 10);
      case MealType.dinner:
        return const Color.fromARGB(255, 27, 45, 207);
      case MealType.snack:
        return const Color.fromARGB(255, 146, 21, 214);
    }
  }

  /// A subtle background tint derived from the accent color
  Color get lightBackgroundColor {
    switch (this) {
      case MealType.breakfast:
        return const Color.fromARGB(255, 255, 238, 209);
      case MealType.lunch:
        return const Color.fromARGB(235, 209, 255, 207);
      case MealType.dinner:
        return const Color.fromARGB(255, 211, 216, 255);
      case MealType.snack:
        return const Color.fromRGBO(240, 212, 255, 1);
    }
  }
}

class DiaryEntry {
  final int id;
  final DateTime date;
  final MealType mealType;
  final int? foodId;
  final String foodName;
  double? calories;
  double? grams;
  double? carbs;
  double? sugars;
  double? fiber;
  double? fat;
  double? saturatedFat;
  double? protein;
  final double? foodCalories;
  final double? foodGrams;
  final double? foodCarbs;
  final double? foodSugars;
  final double? foodFiber;
  final double? foodFat;
  final double? foodSaturatedFat;
  final double? foodProtein;

  DiaryEntry(
    {required this.id, 
    required this.date, 
    required this.mealType, 
    required this.foodName, 
    this.foodId, 
    this.calories = 0.0, 
    this.grams = 0.0, 
    this.carbs = 0.0, 
    this.sugars = 0.0, 
    this.fiber = 0.0, 
    this.fat = 0.0, 
    this.saturatedFat = 0.0, 
    this.protein = 0.0,
    this.foodCalories = 0.0, 
    this.foodGrams = 0.0, 
    this.foodCarbs = 0.0, 
    this.foodSugars = 0.0, 
    this.foodFiber = 0.0, 
    this.foodFat = 0.0, 
    this.foodSaturatedFat = 0.0, 
    this.foodProtein = 0.0
    });

  factory DiaryEntry.fromFood({
    required Food food,
    required MealType mealType,
    required DateTime date,
  }) {
    DiaryEntry entry = DiaryEntry(
      id: -1,
      mealType: mealType,
      date: date,
      foodName: food.name,
      foodId: food.id,
      calories: food.calories,
      grams: food.grams,
      carbs: food.carbs,
      sugars: food.sugars,
      fiber: food.fiber,
      fat: food.fat,
      saturatedFat: food.saturatedFat,
      protein: food.protein,
      foodCalories: food.calories,
      foodGrams: food.grams,
      foodCarbs: food.carbs,
      foodSugars: food.sugars,
      foodFiber: food.fiber,
      foodFat: food.fat,
      foodSaturatedFat: food.saturatedFat,
      foodProtein: food.protein,
    );
    if (food.lastUsedQuantity != null && food.lastUsedQuantity != 0){
      entry.grams = food.lastUsedQuantity;
      entry.calculateAllValuesFromGrams();      
    }
    return entry;
  }

  Map<String, dynamic> toMap() {
    return {
      //if (id != 0) 'id': id,
      'date': date.toIso8601String(),
      'meal_type': mealType.name, // e.g., 'breakfast'
      'food_name': foodName,
      'food_id' : foodId,
      'calories': calories,
      'grams': grams,
      'carbs': carbs,
      'sugars': sugars,
      'fiber': fiber,
      'fat': fat,
      'saturated_fat': saturatedFat,
      'protein': protein,
      'foodCalories': foodCalories,
      'foodGrams': foodGrams,
      'foodCarbs': foodCarbs,
      'foodSugars': foodSugars,
      'foodFiber': foodFiber,
      'foodFat': foodFat,
      'foodSaturated_fat': foodSaturatedFat,
      'foodProtein': foodProtein,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: (map['id'] as num?)?.toInt() ?? 0,
      date: map['date'] != null 
          ? DateTime.parse(map['date'] as String) 
          : DateTime.now(),
      mealType: map['meal_type'] != null 
          ? MealType.values.byName(map['meal_type'] as String) 
          : MealType.breakfast,
      
      // Safely handles foodId whether stored as int, String, or null
      foodId: map['food_id'] is int 
          ? map['food_id'] as int? 
          : int.tryParse(map['food_id']?.toString() ?? ''),
          
      foodName: map['food_name'] as String? ?? 'Unknown Food',

      // Null-safe numeric conversions (as num?) ?? default_value
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      grams: (map['grams'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      sugars: (map['sugars'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      saturatedFat: (map['saturated_fat'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,

      foodCalories: (map['foodCalories'] as num?)?.toDouble() ?? 0.0,
      foodGrams: (map['foodGrams'] as num?)?.toDouble() ?? 0.0,
      foodCarbs: (map['foodCarbs'] as num?)?.toDouble() ?? 0.0,
      foodSugars: (map['foodSugars'] as num?)?.toDouble() ?? 0.0,
      foodFiber: (map['foodFiber'] as num?)?.toDouble() ?? 0.0,
      foodFat: (map['foodFat'] as num?)?.toDouble() ?? 0.0,
      foodSaturatedFat: (map['foodSaturated_fat'] as num?)?.toDouble() ?? 0.0,
      foodProtein: (map['foodProtein'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double getGramsBasedOnCalories(double newCalories) {
    if (newCalories == 0 || foodCalories == null || foodCalories == 0) return 0.0;
    double factor = newCalories / foodCalories!;
    return foodGrams! * factor;
  }

  void calculateAllValuesFromGrams() {
    if (grams == null || foodGrams == null || foodGrams == 0) return;

    double factor = grams! / foodGrams!;

    calories = roundToTwoDecimals((foodCalories ?? 0.0) * factor);
    carbs = roundToTwoDecimals((foodCarbs ?? 0.0) * factor);
    sugars = roundToTwoDecimals((foodSugars ?? 0.0) * factor);
    fiber = roundToTwoDecimals((foodFiber ?? 0.0) * factor);
    fat = roundToTwoDecimals((foodFat ?? 0.0) * factor);
    saturatedFat = roundToTwoDecimals((foodSaturatedFat ?? 0.0) * factor);
    protein = roundToTwoDecimals((foodProtein ?? 0.0) * factor);
  }

  double roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }

}
