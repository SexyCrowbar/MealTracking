import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [SettingsKv])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<Map<String, String>> getAll() async {
    final rows = await select(settingsKv).get();
    return {for (final r in rows) r.key: r.value};
  }

  Stream<Map<String, String>> watchAll() {
    return select(settingsKv).watch().map(
          (rows) => {for (final r in rows) r.key: r.value},
        );
  }

  Future<void> setValue(String key, String value) async {
    await into(settingsKv).insert(
      SettingsKvCompanion(key: Value(key), value: Value(value)),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<String?> getValue(String key) async {
    final r = await (select(settingsKv)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return r?.value;
  }
}
