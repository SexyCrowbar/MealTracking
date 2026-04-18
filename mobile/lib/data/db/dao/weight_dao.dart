import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'weight_dao.g.dart';

@DriftAccessor(tables: [WeightEntries])
class WeightDao extends DatabaseAccessor<AppDatabase> with _$WeightDaoMixin {
  WeightDao(super.db);

  Future<int> upsertWeight(WeightEntriesCompanion entry) =>
      into(weightEntries).insert(entry, mode: InsertMode.insertOrReplace);

  Future<int> deleteEntry(int id) =>
      (delete(weightEntries)..where((w) => w.id.equals(id))).go();

  Stream<List<WeightEntryRow>> watchAll() {
    final q = select(weightEntries)
      ..orderBy([(w) => OrderingTerm.asc(w.date)]);
    return q.watch();
  }

  Future<List<WeightEntryRow>> getRecent(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffIso = '${cutoff.year.toString().padLeft(4, '0')}-'
        '${cutoff.month.toString().padLeft(2, '0')}-'
        '${cutoff.day.toString().padLeft(2, '0')}';
    final q = select(weightEntries)
      ..where((w) => w.date.isBiggerOrEqualValue(cutoffIso))
      ..orderBy([(w) => OrderingTerm.asc(w.date)]);
    return q.get();
  }
}
