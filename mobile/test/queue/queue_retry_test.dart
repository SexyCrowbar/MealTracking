import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtracker/data/db/database.dart';
import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  test('markFailed + bumpRetry accumulates retryCount across failures',
      () async {
    final id = await db.queueDao.enqueue(
      const AnalysisQueueCompanion(textDescription: Value('test item')),
    );

    for (var expected = 1; expected <= 4; expected++) {
      await db.queueDao.markFailed(id, 'boom');
      await db.queueDao.bumpRetry(id);
      final row = await (db.select(db.analysisQueue)
            ..where((r) => r.id.equals(id)))
          .getSingle();
      expect(
        row.retryCount,
        expected,
        reason: 'retryCount must climb ($expected), not reset to 1',
      );
      expect(row.status, 'pending');
    }
  });

  test('markFailed without bumpRetry leaves retryCount unchanged', () async {
    final id = await db.queueDao.enqueue(
      const AnalysisQueueCompanion(textDescription: Value('test')),
    );
    await db.queueDao.bumpRetry(id); // set to 1
    await db.queueDao.markFailed(id, 'boom'); // should NOT reset count

    final row = await (db.select(db.analysisQueue)
          ..where((r) => r.id.equals(id)))
        .getSingle();
    expect(row.retryCount, 1);
  });
}
