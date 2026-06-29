import 'package:drift/native.dart';
import 'package:mealtracker/data/db/database.dart';

/// Builds an isolated in-memory [AppDatabase] for tests.
/// Each call gets a fresh schema (latest version, migrations applied by drift).
AppDatabase newTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
