import 'package:drift/drift.dart' show Value;

import '../../domain/models/meal.dart';
import '../../domain/models/meal_analysis.dart';
import '../db/dao/meal_dao.dart';
import '../db/database.dart';

class MealsRepository {
  MealsRepository(this._dao);

  final MealDao _dao;

  Stream<List<Meal>> watchByDate(String isoDate) =>
      _dao.watchByDate(isoDate).map((rows) => rows.map(_toModel).toList());

  Future<List<Meal>> getByDate(String isoDate) async =>
      (await _dao.getByDate(isoDate)).map(_toModel).toList();

  Stream<List<Meal>> watchAllRecent(int days) =>
      _dao.watchAllRecent(days).map((rows) => rows.map(_toModel).toList());

  Future<List<Meal>> getDateRange(String startIso, String endIso) async =>
      (await _dao.getDateRange(startIso, endIso))
          .map(_toModel)
          .toList();

  Future<int> insertManual({
    required String name,
    required int calories,
    double? protein,
    double? carbs,
    double? fat,
    int? glycemicIndex,
    double? estimatedInsulin,
    DateTime? at,
  }) async {
    final dt = at ?? DateTime.now();
    return _dao.insertMeal(
      MealsCompanion(
        date: Value(_isoDate(dt)),
        time: Value(_isoTime(dt)),
        name: Value(name),
        calories: Value(calories),
        protein: Value(protein),
        carbs: Value(carbs),
        fat: Value(fat),
        glycemicIndex: Value(glycemicIndex),
        estimatedInsulin: Value(estimatedInsulin),
        source: const Value('manual'),
      ),
    );
  }

  Future<int> insertFromAnalysis(
    MealAnalysis analysis, {
    required String source,
    DateTime? at,
  }) async {
    final dt = at ?? DateTime.now();
    return _dao.insertMeal(
      MealsCompanion(
        date: Value(_isoDate(dt)),
        time: Value(_isoTime(dt)),
        name: Value(analysis.name),
        calories: Value(analysis.calories),
        protein: Value(analysis.protein),
        carbs: Value(analysis.carbs),
        fat: Value(analysis.fat),
        glycemicIndex: Value(analysis.glycemicIndex),
        healthScore: Value(analysis.healthScore),
        allergenWarning: Value(analysis.allergenWarning),
        estimatedInsulin: Value(analysis.estimatedInsulin),
        source: Value(source),
        provider: Value(analysis.providerUsed),
        model: Value(analysis.modelUsed),
        analysisLatencyMs: Value(analysis.latencyMs),
      ),
    );
  }

  static String sourceFor({required bool hadImage, required bool hadText}) {
    if (!hadImage) return 'ai_text';
    return hadText ? 'ai_photo_text' : 'ai_photo';
  }

  Future<int> deleteMeal(int id) => _dao.deleteMeal(id);

  Future<void> updateMeal(Meal meal) async {
    await _dao.updateMeal(MealRow(
      id: meal.id,
      date: meal.date,
      time: meal.time,
      name: meal.name,
      calories: meal.calories,
      protein: meal.protein,
      carbs: meal.carbs,
      fat: meal.fat,
      glycemicIndex: meal.glycemicIndex,
      healthScore: meal.healthScore,
      allergenWarning: meal.allergenWarning,
      estimatedInsulin: meal.estimatedInsulin,
      source: meal.source,
      provider: meal.provider,
      model: meal.model,
      analysisLatencyMs: meal.analysisLatencyMs,
      createdAt: meal.createdAt,
    ));
  }

  Meal _toModel(MealRow r) => Meal(
        id: r.id,
        date: r.date,
        time: r.time,
        name: r.name,
        calories: r.calories,
        protein: r.protein,
        carbs: r.carbs,
        fat: r.fat,
        glycemicIndex: r.glycemicIndex,
        healthScore: r.healthScore,
        allergenWarning: r.allergenWarning,
        estimatedInsulin: r.estimatedInsulin,
        source: r.source,
        provider: r.provider,
        model: r.model,
        analysisLatencyMs: r.analysisLatencyMs,
        createdAt: r.createdAt,
      );

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
  String _isoTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}
