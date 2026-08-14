
class Settings {
  int id;
  double? caloriesMin;
  double? caloriesMax;
  double? carbsMin;
  double? carbsMax;
  double? sugarsMin;
  double? sugarsMax;
  double? fiberMin;
  double? fiberMax;
  double? fatMin;
  double? fatMax;
  double? saturatedfatMin;
  double? saturatedfatMax;
  double? proteinMin;
  double? proteinMax;
  double? weightGoal;


  Settings(
    {required this.id, 
    this.caloriesMin = 0.0, 
    this.caloriesMax = 0.0, 
    this.carbsMin = 0.0, 
    this.carbsMax = 0.0, 
    this.sugarsMin = 0.0, 
    this.sugarsMax = 0.0, 
    this.fiberMin = 0.0, 
    this.fiberMax = 0.0, 
    this.fatMin = 0.0, 
    this.fatMax = 0.0, 
    this.saturatedfatMin = 0.0, 
    this.saturatedfatMax = 0.0, 
    this.proteinMin = 0.0, 
    this.proteinMax = 0.0,
    this.weightGoal});

    Map<String, dynamic> toMap() {
    return {
      'caloriesMin': caloriesMin,
      'caloriesMax': caloriesMin,
      'carbsMin': carbsMin,
      'carbsMax': carbsMin,
      'sugarsMin': sugarsMin,
      'sugarsMax': sugarsMin,
      'fiberMin': fiberMin,
      'fiberMax': fiberMin,
      'fatMin': fatMin,
      'fatMax': fatMin,
      'saturatedfatMin': saturatedfatMin,
      'saturatedfatMax': saturatedfatMin,
      'proteinMin': proteinMin,
      'proteinMax': proteinMin,
      'weightGoal': weightGoal,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'] as int,
      caloriesMin: map['caloriesMin'] != null ? (map['caloriesMin'] as num).toDouble() : null,
      caloriesMax: map['caloriesMax'] != null ? (map['caloriesMax'] as num).toDouble() : null,
      carbsMin: map['carbsMin'] != null ? (map['carbsMin'] as num).toDouble() : null,
      carbsMax: map['carbsMax'] != null ? (map['carbsMax'] as num).toDouble() : null,
      sugarsMin: map['sugarsMin'] != null ? (map['sugarsMin'] as num).toDouble() : null,
      sugarsMax: map['sugarsMax'] != null ? (map['sugarsMax'] as num).toDouble() : null,
      fiberMin: map['fiberMin'] != null ? (map['fiberMin'] as num).toDouble() : null,
      fiberMax: map['fiberMax'] != null ? (map['fiberMax'] as num).toDouble() : null,
      fatMin: map['fatMin'] != null ? (map['fatMin'] as num).toDouble() : null,
      fatMax: map['fatMax'] != null ? (map['fatMax'] as num).toDouble() : null,
      saturatedfatMin: map['saturatedfatMin'] != null? (map['saturatedfatMin'] as num).toDouble(): null,
      saturatedfatMax: map['saturatedfatMax'] != null? (map['saturatedfatMax'] as num).toDouble(): null,
      proteinMin: map['proteinMin'] != null ? (map['proteinMin'] as num).toDouble() : null,
      proteinMax: map['proteinMax'] != null ? (map['proteinMax'] as num).toDouble() : null,
      weightGoal: map['weightGoal'] != null ? (map['weightGoal'] as num).toDouble() : null,);
  }
}