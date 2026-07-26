
class Food {
  int id;
  String name;
  double calories;
  double grams;
  double? carbs;
  double? sugars;
  double? fiber;
  double? fat;
  double? saturatedFat;
  double? protein;

  Food(
    {required this.id, 
    required this.name, 
    this.calories = 0.0, 
    this.grams = 0.0, 
    this.carbs = 0.0, 
    this.sugars = 0.0, 
    this.fiber = 0.0, 
    this.fat = 0.0, 
    this.saturatedFat = 0.0, 
    this.protein = 0.0});

    Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'grams': grams,
      'carbs': carbs,
      'sugars': sugars,
      'fiber': fiber,
      'fat': fat,
      'saturated_fat': saturatedFat,
      'protein': protein,
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] as int,
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
      grams: (map['grams'] as num).toDouble(),
      carbs: map['carbs'] != null ? (map['carbs'] as num).toDouble() : null,
      sugars: map['sugars'] != null ? (map['sugars'] as num).toDouble() : null,
      fiber: map['fiber'] != null ? (map['fiber'] as num).toDouble() : null,
      fat: map['fat'] != null ? (map['fat'] as num).toDouble() : null,
      saturatedFat: map['saturated_fat'] != null
          ? (map['saturated_fat'] as num).toDouble()
          : null,
      protein: map['protein'] != null ? (map['protein'] as num).toDouble() : null,
    );
  }
}