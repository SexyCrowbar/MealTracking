class MealAnalysis {
  const MealAnalysis({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.glycemicIndex,
    this.healthScore,
    this.allergenWarning,
    this.estimatedInsulin,
    required this.providerUsed,
    required this.modelUsed,
    required this.latencyMs,
  });

  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final int? glycemicIndex;
  final double? healthScore;
  final String? allergenWarning;
  final double? estimatedInsulin;
  final String providerUsed;
  final String modelUsed;
  final int latencyMs;

  MealAnalysis copyWith({
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
      MealAnalysis(
        name: name ?? this.name,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        carbs: carbs ?? this.carbs,
        fat: fat ?? this.fat,
        glycemicIndex: glycemicIndex ?? this.glycemicIndex,
        healthScore: healthScore ?? this.healthScore,
        allergenWarning: allergenWarning ?? this.allergenWarning,
        estimatedInsulin: estimatedInsulin ?? this.estimatedInsulin,
        providerUsed: providerUsed,
        modelUsed: modelUsed,
        latencyMs: latencyMs,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        if (glycemicIndex != null) 'glycemic_index': glycemicIndex,
        if (healthScore != null) 'health_score': healthScore,
        if (allergenWarning != null) 'allergen_warning': allergenWarning,
        if (estimatedInsulin != null) 'estimated_insulin': estimatedInsulin,
        'provider_used': providerUsed,
        'model_used': modelUsed,
        'latency_ms': latencyMs,
      };
}
