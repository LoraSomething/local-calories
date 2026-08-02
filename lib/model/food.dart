
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

  final DateTime? lastUsedAt;
  final double? lastUsedQuantity;

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
    this.protein = 0.0, 
    this.lastUsedAt, 
    this.lastUsedQuantity});

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
      lastUsedAt: map['lastUsedAt'] != null 
          ? DateTime.parse(map['lastUsedAt'] as String) 
          : null,
      lastUsedQuantity: map['lastUsedQuantity'] != null ? (map['lastUsedQuantity'] as num).toDouble() : null,
    );
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numbers, strings, or missing keys into a valid double
    double _parseNum(List<String> possibleKeys) {
      for (final key in possibleKeys) {
        if (json.containsKey(key) && json[key] != null) {
          final val = json[key];
          
          // 1. If it's already a number
          if (val is num) return val.toDouble();
          
          // 2. If it's a string (e.g., "150.0", "1 potato", "150g")
          if (val is String) {
            // Strip everything except numbers and decimal points
            final clean = val.replaceAll(RegExp(r'[^0-9.]'), '');
            final parsed = double.tryParse(clean);
            if (parsed != null) return parsed;
          }
        }
      }
      return 0.0; // Default fallback if key is missing or unparseable
    }

    return Food(
      id: -1,
      name: json['name'] is String ? json['name'] as String : "",
      grams: json['grams'] is int ? json['grams'] as double : 100,
      
      // Checks primary key AND fallback key names in case LLM drops the suffix
      calories: _parseNum(['calories_kcal', 'calories', 'kcal']),
      carbs: _parseNum(['carbohydrates_g', 'carbohydrates', 'carbs']),
      sugars: _parseNum(['sugars_g', 'sugars']),
      fiber: _parseNum(['fiber_g', 'fiber']),
      fat: _parseNum(['fat_g', 'fat']),
      saturatedFat: _parseNum(['saturated_fat_g', 'saturated_fat', 'saturatedFat']),
      protein: _parseNum(['protein_g', 'protein']),
    );
  }
}