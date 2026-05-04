class MealExtra {
  const MealExtra({required this.description, required this.grams});
  final String description;
  final double grams;

  Map<String, dynamic> toJson() => {'d': description, 'g': grams};

  static MealExtra? fromJson(dynamic v) {
    if (v is! Map) return null;
    final d = v['d'];
    final g = v['g'];
    if (d is! String || d.trim().isEmpty) return null;
    final grams = g is num ? g.toDouble() : null;
    if (grams == null || grams <= 0) return null;
    return MealExtra(description: d.trim(), grams: grams);
  }
}

class Meal {
  const Meal({
    required this.id,
    required this.date,
    required this.time,
    required this.name,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.glycemicIndex,
    this.healthScore,
    this.allergenWarning,
    this.estimatedInsulin,
    required this.source,
    this.provider,
    this.model,
    this.analysisLatencyMs,
    this.extras = const [],
    required this.createdAt,
  });

  final int id;
  final String date; // YYYY-MM-DD
  final String time; // HH:MM
  final String name;
  final int calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final int? glycemicIndex;
  final double? healthScore;
  final String? allergenWarning;
  final double? estimatedInsulin;
  final String source;
  final String? provider;
  final String? model;
  final int? analysisLatencyMs;
  final List<MealExtra> extras;
  final DateTime createdAt;

  bool get hasExtras => extras.isNotEmpty;

  Meal copyWith({
    String? name,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    int? glycemicIndex,
    double? healthScore,
    String? allergenWarning,
    double? estimatedInsulin,
  }) =>
      Meal(
        id: id,
        date: date,
        time: time,
        name: name ?? this.name,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        carbs: carbs ?? this.carbs,
        fat: fat ?? this.fat,
        glycemicIndex: glycemicIndex ?? this.glycemicIndex,
        healthScore: healthScore ?? this.healthScore,
        allergenWarning: allergenWarning ?? this.allergenWarning,
        estimatedInsulin: estimatedInsulin ?? this.estimatedInsulin,
        source: source,
        provider: provider,
        model: model,
        analysisLatencyMs: analysisLatencyMs,
        extras: extras,
        createdAt: createdAt,
      );
}
