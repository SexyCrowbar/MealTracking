import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'meal_dao.g.dart';

@DriftAccessor(tables: [Meals])
class MealDao extends DatabaseAccessor<AppDatabase> with _$MealDaoMixin {
  MealDao(super.db);

  Future<int> insertMeal(MealsCompanion entry) =>
      into(meals).insert(entry);

  Future<void> updateMeal(MealRow row) =>
      update(meals).replace(row);

  Future<int> deleteMeal(int id) =>
      (delete(meals)..where((m) => m.id.equals(id))).go();

  Stream<List<MealRow>> watchByDate(String isoDate) {
    final q = select(meals)
      ..where((m) => m.date.equals(isoDate))
      ..orderBy([(m) => OrderingTerm.asc(m.time)]);
    return q.watch();
  }

  Future<List<MealRow>> getByDate(String isoDate) {
    final q = select(meals)
      ..where((m) => m.date.equals(isoDate))
      ..orderBy([(m) => OrderingTerm.asc(m.time)]);
    return q.get();
  }

  Stream<List<MealRow>> watchAllRecent(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffIso = '${cutoff.year.toString().padLeft(4, '0')}-'
        '${cutoff.month.toString().padLeft(2, '0')}-'
        '${cutoff.day.toString().padLeft(2, '0')}';
    final q = select(meals)
      ..where((m) => m.date.isBiggerOrEqualValue(cutoffIso))
      ..orderBy([
        (m) => OrderingTerm.desc(m.date),
        (m) => OrderingTerm.desc(m.time),
      ]);
    return q.watch();
  }

  Future<List<MealRow>> getDateRange(String startIso, String endIso) {
    final q = select(meals)
      ..where((m) =>
          m.date.isBiggerOrEqualValue(startIso) &
          m.date.isSmallerOrEqualValue(endIso))
      ..orderBy([
        (m) => OrderingTerm.asc(m.date),
        (m) => OrderingTerm.asc(m.time),
      ]);
    return q.get();
  }
}
