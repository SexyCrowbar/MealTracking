import 'package:drift/drift.dart' show Value;

import '../db/dao/saved_meal_dao.dart';
import '../db/database.dart';

class RecipeIngredientInput {
  const RecipeIngredientInput({required this.description, required this.grams});
  final String description;
  final double grams;
}

class SavedMealsRepository {
  SavedMealsRepository(this._dao);

  final SavedMealDao _dao;

  Stream<List<SavedMealRow>> watchAll() => _dao.watchAll();

  Future<SavedMealRow?> getById(int id) => _dao.getById(id);

  Future<SavedMealWithIngredients?> getWithIngredients(int id) =>
      _dao.getWithIngredients(id);

  Future<List<SavedMealIngredientRow>> ingredientsFor(int id) =>
      _dao.ingredientsFor(id);

  Future<int> insert({
    required String name,
    required List<RecipeIngredientInput> ingredients,
    required int totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    int? glycemicIndex,
    String? provider,
    String? model,
  }) {
    final totalG = _sumGrams(ingredients);
    final perHundred = _perHundred(
      totalG: totalG,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
    );
    return _dao.insertWithIngredients(
      meal: SavedMealsCompanion(
        name: Value(name),
        totalWeightG: Value(totalG),
        caloriesPer100g: Value(perHundred.calories),
        proteinPer100g: Value(perHundred.protein),
        carbsPer100g: Value(perHundred.carbs),
        fatPer100g: Value(perHundred.fat),
        glycemicIndex: Value(glycemicIndex),
        totalCalories: Value(totalCalories),
        totalProtein: Value(totalProtein),
        totalCarbs: Value(totalCarbs),
        totalFat: Value(totalFat),
        provider: Value(provider),
        model: Value(model),
      ),
      ingredients: _toCompanions(ingredients),
    );
  }

  Future<void> update({
    required int id,
    required String name,
    required List<RecipeIngredientInput> ingredients,
    required int totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    int? glycemicIndex,
    String? provider,
    String? model,
  }) {
    final totalG = _sumGrams(ingredients);
    final perHundred = _perHundred(
      totalG: totalG,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
    );
    return _dao.updateWithIngredients(
      id: id,
      meal: SavedMealsCompanion(
        name: Value(name),
        totalWeightG: Value(totalG),
        caloriesPer100g: Value(perHundred.calories),
        proteinPer100g: Value(perHundred.protein),
        carbsPer100g: Value(perHundred.carbs),
        fatPer100g: Value(perHundred.fat),
        glycemicIndex: Value(glycemicIndex),
        totalCalories: Value(totalCalories),
        totalProtein: Value(totalProtein),
        totalCarbs: Value(totalCarbs),
        totalFat: Value(totalFat),
        provider: Value(provider),
        model: Value(model),
      ),
      ingredients: _toCompanions(ingredients),
    );
  }

  Future<int> delete(int id) => _dao.deleteSavedMeal(id);

  static double _sumGrams(List<RecipeIngredientInput> ings) =>
      ings.fold<double>(0, (s, i) => s + i.grams);

  static List<SavedMealIngredientsCompanion> _toCompanions(
      List<RecipeIngredientInput> ings) {
    return [
      for (var i = 0; i < ings.length; i++)
        SavedMealIngredientsCompanion(
          position: Value(i),
          description: Value(ings[i].description.trim()),
          grams: Value(ings[i].grams),
        )
    ];
  }

  static _PerHundred _perHundred({
    required double totalG,
    required int totalCalories,
    required double? totalProtein,
    required double? totalCarbs,
    required double? totalFat,
  }) {
    if (totalG <= 0) {
      return _PerHundred(
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
      );
    }
    final factor = 100.0 / totalG;
    return _PerHundred(
      calories: (totalCalories * factor).round(),
      protein: totalProtein == null ? null : totalProtein * factor,
      carbs: totalCarbs == null ? null : totalCarbs * factor,
      fat: totalFat == null ? null : totalFat * factor,
    );
  }
}

class _PerHundred {
  const _PerHundred({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  final int calories;
  final double? protein;
  final double? carbs;
  final double? fat;
}
