import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtracker/data/db/database.dart';
import 'package:mealtracker/data/repositories/meals_repo.dart';
import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late MealsRepository repo;

  setUp(() {
    db = newTestDatabase();
    repo = MealsRepository(db.mealDao);
  });

  tearDown(() => db.close());

  test('updateMeal preserves savedMealId and extrasJson', () async {
    // Insert a meal that carries a saved-meal link + extras directly via DAO.
    final id = await db.mealDao.insertMeal(MealsCompanion(
      date: const Value('2026-06-29'),
      time: const Value('12:00'),
      name: const Value('Soup + ketchup'),
      calories: const Value(300),
      source: const Value('saved_meal'),
      savedMealId: const Value(7),
      extrasJson: const Value('[{"d":"ketchup","g":30}]'),
    ));

    final meals = await repo.getByDate('2026-06-29');
    expect(meals, hasLength(1));
    final edited = meals.first;

    // Edit the meal (e.g. change calories) — this should NOT wipe savedMealId/extrasJson.
    await repo.updateMeal(edited.copyWith(calories: 350));

    final row =
        await (db.select(db.meals)..where((m) => m.id.equals(id))).getSingle();
    expect(row.savedMealId, 7);
    expect(row.extrasJson, '[{"d":"ketchup","g":30}]');
    expect(row.calories, 350); // edit applied
    expect(row.name, 'Soup + ketchup'); // unchanged
  });

  test('updateMeal with no savedMealId/extrasJson round-trips cleanly',
      () async {
    final id = await db.mealDao.insertMeal(MealsCompanion(
      date: const Value('2026-06-30'),
      time: const Value('08:00'),
      name: const Value('Toast'),
      calories: const Value(150),
      source: const Value('manual'),
    ));

    final meals = await repo.getByDate('2026-06-30');
    expect(meals, hasLength(1));
    final meal = meals.first;
    expect(meal.savedMealId, equals(null));
    expect(meal.extras, isEmpty);

    await repo.updateMeal(meal); // no-op edit

    final row =
        await (db.select(db.meals)..where((m) => m.id.equals(id))).getSingle();
    expect(row.savedMealId, equals(null));
    expect(row.extrasJson, equals(null));
  });
}
