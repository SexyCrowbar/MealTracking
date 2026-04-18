import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'dao/meal_dao.dart';
import 'dao/profile_dao.dart';
import 'dao/queue_dao.dart';
import 'dao/settings_dao.dart';
import 'dao/weight_dao.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Profiles, Meals, WeightEntries, AnalysisQueue, SettingsKv],
  daos: [ProfileDao, MealDao, WeightDao, QueueDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_meals_date ON meals(date)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_weight_date ON weight_entries(date)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_queue_status ON analysis_queue(status)');
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Drop NOT NULL on analysis_queue.image_path by rebuilding the table.
            await customStatement('PRAGMA foreign_keys = OFF');
            await customStatement('''
              CREATE TABLE analysis_queue_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                image_path TEXT,
                text_description TEXT,
                status TEXT NOT NULL DEFAULT 'pending',
                retry_count INTEGER NOT NULL DEFAULT 0,
                error_message TEXT,
                result_json TEXT,
                created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
                processed_at INTEGER
              )
            ''');
            await customStatement('''
              INSERT INTO analysis_queue_new (id, image_path, text_description, status, retry_count, error_message, result_json, created_at, processed_at)
              SELECT id, image_path, text_description, status, retry_count, error_message, result_json, created_at, processed_at FROM analysis_queue
            ''');
            await customStatement('DROP TABLE analysis_queue');
            await customStatement(
                'ALTER TABLE analysis_queue_new RENAME TO analysis_queue');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_queue_status ON analysis_queue(status)');
            await customStatement('PRAGMA foreign_keys = ON');
          }
        },
      );

  Future<void> pruneOlderThan(int days) async {
    if (days <= 0) return; // unlimited
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffIso = '${cutoff.year.toString().padLeft(4, '0')}-'
        '${cutoff.month.toString().padLeft(2, '0')}-'
        '${cutoff.day.toString().padLeft(2, '0')}';
    await customStatement(
      'DELETE FROM meals WHERE date < ?',
      [cutoffIso],
    );
    await customStatement(
      'DELETE FROM weight_entries WHERE date < ?',
      [cutoffIso],
    );
    await customStatement(
      "DELETE FROM analysis_queue WHERE status IN ('completed','failed') AND created_at < ?",
      [cutoff.toIso8601String()],
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mealtracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
