import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'queue_dao.g.dart';

@DriftAccessor(tables: [AnalysisQueue])
class QueueDao extends DatabaseAccessor<AppDatabase> with _$QueueDaoMixin {
  QueueDao(super.db);

  Future<int> enqueue(AnalysisQueueCompanion entry) =>
      into(analysisQueue).insert(entry);

  Future<List<AnalysisQueueRow>> getPending() {
    final q = select(analysisQueue)
      ..where((r) => r.status.equals('pending') | r.status.equals('processing'))
      ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]);
    return q.get();
  }

  Stream<List<AnalysisQueueRow>> watchPending() {
    final q = select(analysisQueue)
      ..where((r) => r.status.equals('pending') | r.status.equals('processing'))
      ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]);
    return q.watch();
  }

  Future<void> markProcessing(int id) async {
    await (update(analysisQueue)..where((r) => r.id.equals(id))).write(
      const AnalysisQueueCompanion(status: Value('processing')),
    );
  }

  Future<void> markCompleted(int id, String resultJson) async {
    await (update(analysisQueue)..where((r) => r.id.equals(id))).write(
      AnalysisQueueCompanion(
        status: const Value('completed'),
        resultJson: Value(resultJson),
        processedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks a row back to 'pending' for a later retry. Does NOT touch
  /// [retryCount] — the caller bumps it via [bumpRetry].
  Future<void> markFailed(int id, String error) async {
    await (update(analysisQueue)..where((r) => r.id.equals(id))).write(
      AnalysisQueueCompanion(
        status: const Value('pending'),
        errorMessage: Value(error),
      ),
    );
  }

  Future<void> bumpRetry(int id) async {
    final row = await (select(analysisQueue)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;
    await (update(analysisQueue)..where((r) => r.id.equals(id))).write(
      AnalysisQueueCompanion(retryCount: Value(row.retryCount + 1)),
    );
  }

  Future<int> deleteEntry(int id) =>
      (delete(analysisQueue)..where((r) => r.id.equals(id))).go();
}
