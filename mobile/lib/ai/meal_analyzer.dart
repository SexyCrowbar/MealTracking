import 'dart:typed_data';

import '../domain/models/meal_analysis.dart';
import '../domain/models/profile.dart';

class ModelOption {
  const ModelOption({required this.id, required this.label});
  final String id;
  final String label;
}

class RecipeIngredient {
  const RecipeIngredient({required this.description, required this.grams});
  final String description;
  final double grams;
}

class AnalysisRequest {
  const AnalysisRequest({
    this.imageBytes,
    this.textDescription,
    required this.apiKey,
    required this.model,
    required this.allergens,
    this.profile,
    this.diabeticRatio,
    this.recipeIngredients,
  });

  final Uint8List? imageBytes;
  final String? textDescription;
  final String apiKey;
  final String model;
  final List<String> allergens;
  final Profile? profile;
  final double? diabeticRatio;

  /// When non-null, the request is a recipe-totals computation.
  /// The adapter will ignore [imageBytes]/[textDescription] and use a
  /// recipe-specific prompt that asks for sums across the listed ingredients.
  final List<RecipeIngredient>? recipeIngredients;

  bool get hasImage => imageBytes != null && imageBytes!.isNotEmpty;
  bool get isRecipe =>
      recipeIngredients != null && recipeIngredients!.isNotEmpty;
}

abstract class MealAnalyzer {
  String get providerId;
  String get providerName;
  String get providerDescription;
  List<ModelOption> get availableModels;
  String get defaultModel;
  String get setupUrl;

  Future<MealAnalysis> analyzeMeal(AnalysisRequest request);

  Future<bool> validateApiKey(String apiKey, String model);
}

class AiAnalysisException implements Exception {
  AiAnalysisException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  bool get isOverloaded {
    if (statusCode == 429 || statusCode == 503) return true;
    final m = message.toLowerCase();
    return m.contains('overload') ||
        m.contains('high demand') ||
        m.contains('unavailable') ||
        m.contains('resource_exhausted') ||
        m.contains('rate limit') ||
        m.contains('try again later');
  }

  @override
  String toString() => 'AiAnalysisException($statusCode): $message';
}
