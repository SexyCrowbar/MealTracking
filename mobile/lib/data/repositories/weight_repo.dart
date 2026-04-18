import 'package:drift/drift.dart' show Value;

import '../../domain/models/weight_entry.dart';
import '../db/dao/weight_dao.dart';
import '../db/database.dart';

class WeightRepository {
  WeightRepository(this._dao);

  final WeightDao _dao;

  Stream<List<WeightEntry>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_toModel).toList());

  Future<List<WeightEntry>> getRecent(int days) async =>
      (await _dao.getRecent(days)).map(_toModel).toList();

  Future<int> addEntry(double weightKg, {DateTime? at}) async {
    final dt = at ?? DateTime.now();
    return _dao.upsertWeight(WeightEntriesCompanion(
      date: Value(_isoDate(dt)),
      weightKg: Value(weightKg),
    ));
  }

  Future<int> deleteEntry(int id) => _dao.deleteEntry(id);

  WeightEntry _toModel(WeightEntryRow r) => WeightEntry(
        id: r.id,
        date: r.date,
        weightKg: r.weightKg,
        createdAt: r.createdAt,
      );

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
