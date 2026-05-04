import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../core/constants.dart';
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

  /// Logs a portion of a saved recipe.
  ///
  /// [extras] is an optional list of ad-hoc ingredients added at log time
  /// (e.g. ketchup poured on the bowl). [extrasTotals] holds AI-computed
  /// totals (calories + macros) for those extras; pass null when there are
  /// no extras. Extras totals are summed into the saved-meal portion totals
  /// before the row is inserted, and the extras list is preserved as JSON.
  Future<int> insertFromSavedMeal({
    required SavedMealRow meal,
    required double weightG,
    List<MealExtra> extras = const [],
    MealAnalysis? extrasTotals,
    DateTime? at,
  }) async {
    final dt = at ?? DateTime.now();
    final factor = weightG / 100.0;
    final baseCalories = (meal.caloriesPer100g * factor).round();
    final baseProtein = _scale(meal.proteinPer100g, factor);
    final baseCarbs = _scale(meal.carbsPer100g, factor);
    final baseFat = _scale(meal.fatPer100g, factor);

    final hasExtras = extras.isNotEmpty;
    final calories =
        baseCalories + (hasExtras ? (extrasTotals?.calories ?? 0) : 0);
    final protein = _addOpt(baseProtein, hasExtras ? extrasTotals?.protein : null);
    final carbs = _addOpt(baseCarbs, hasExtras ? extrasTotals?.carbs : null);
    final fat = _addOpt(baseFat, hasExtras ? extrasTotals?.fat : null);

    final name = hasExtras
        ? '${meal.name} + ${extras.map((e) => e.description).join(' + ')}'
        : meal.name;
    final extrasJson =
        hasExtras ? jsonEncode(extras.map((e) => e.toJson()).toList()) : null;

    return _dao.insertMeal(
      MealsCompanion(
        date: Value(_isoDate(dt)),
        time: Value(_isoTime(dt)),
        name: Value(name),
        calories: Value(calories),
        protein: Value(protein),
        carbs: Value(carbs),
        fat: Value(fat),
        glycemicIndex: Value(meal.glycemicIndex),
        source: const Value(MealSource.savedMeal),
        savedMealId: Value(meal.id),
        extrasJson: Value(extrasJson),
        provider: Value(extrasTotals?.providerUsed),
        model: Value(extrasTotals?.modelUsed),
        analysisLatencyMs: Value(extrasTotals?.latencyMs),
      ),
    );
  }

  static double? _scale(double? per100, double factor) =>
      per100 == null ? null : per100 * factor;

  static double? _addOpt(double? a, double? b) {
    if (a == null && b == null) return null;
    return (a ?? 0) + (b ?? 0);
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
        extras: _decodeExtras(r.extrasJson),
        createdAt: r.createdAt,
      );

  static List<MealExtra> _decodeExtras(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const [];
      final out = <MealExtra>[];
      for (final v in decoded) {
        final e = MealExtra.fromJson(v);
        if (e != null) out.add(e);
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
  String _isoTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}
