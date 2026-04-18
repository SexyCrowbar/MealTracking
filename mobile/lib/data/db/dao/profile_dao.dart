import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [Profiles])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Future<ProfileRow?> getProfile() async {
    final query = select(profiles)..limit(1);
    final rows = await query.get();
    return rows.isEmpty ? null : rows.first;
  }

  Stream<ProfileRow?> watchProfile() {
    final query = select(profiles)..limit(1);
    return query.watch().map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<void> upsertProfile(ProfilesCompanion entry) async {
    final existing = await getProfile();
    if (existing == null) {
      await into(profiles).insert(
        entry.copyWith(id: const Value(1), updatedAt: Value(DateTime.now())),
        mode: InsertMode.insertOrReplace,
      );
    } else {
      await (update(profiles)..where((p) => p.id.equals(1))).write(
        entry.copyWith(updatedAt: Value(DateTime.now())),
      );
    }
  }
}
