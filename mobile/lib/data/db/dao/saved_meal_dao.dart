import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'saved_meal_dao.g.dart';

class SavedMealWithIngredients {
  const SavedMealWithIngredients({required this.meal, required this.ingredients});
  final SavedMealRow meal;
  final List<SavedMealIngredientRow> ingredients;
}

@DriftAccessor(tables: [SavedMeals, SavedMealIngredients])
class SavedMealDao extends DatabaseAccessor<AppDatabase>
    with _$SavedMealDaoMixin {
  SavedMealDao(super.db);

  Stream<List<SavedMealRow>> watchAll() {
    final q = select(savedMeals)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return q.watch();
  }

  Future<SavedMealRow?> getById(int id) =>
      (select(savedMeals)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<SavedMealIngredientRow>> ingredientsFor(int savedMealId) {
    final q = select(savedMealIngredients)
      ..where((t) => t.savedMealId.equals(savedMealId))
      ..orderBy([(t) => OrderingTerm.asc(t.position)]);
    return q.get();
  }

  Future<SavedMealWithIngredients?> getWithIngredients(int id) async {
    final meal = await getById(id);
    if (meal == null) return null;
    final ings = await ingredientsFor(id);
    return SavedMealWithIngredients(meal: meal, ingredients: ings);
  }

  Future<int> insertWithIngredients({
    required SavedMealsCompanion meal,
    required List<SavedMealIngredientsCompanion> ingredients,
  }) async {
    return transaction(() async {
      final id = await into(savedMeals).insert(meal);
      for (final ing in ingredients) {
        await into(savedMealIngredients).insert(
          ing.copyWith(savedMealId: Value(id)),
        );
      }
      return id;
    });
  }

  Future<void> updateWithIngredients({
    required int id,
    required SavedMealsCompanion meal,
    required List<SavedMealIngredientsCompanion> ingredients,
  }) async {
    return transaction(() async {
      await (update(savedMeals)..where((t) => t.id.equals(id)))
          .write(meal.copyWith(updatedAt: Value(DateTime.now())));
      await (delete(savedMealIngredients)
            ..where((t) => t.savedMealId.equals(id)))
          .go();
      for (final ing in ingredients) {
        await into(savedMealIngredients).insert(
          ing.copyWith(savedMealId: Value(id)),
        );
      }
    });
  }

  Future<int> deleteSavedMeal(int id) =>
      (delete(savedMeals)..where((t) => t.id.equals(id))).go();
}
