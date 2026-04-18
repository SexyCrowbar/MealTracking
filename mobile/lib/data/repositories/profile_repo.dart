import 'package:drift/drift.dart' show Value;

import '../../domain/models/profile.dart';
import '../db/dao/profile_dao.dart';
import '../db/database.dart';

class ProfileRepository {
  ProfileRepository(this._dao);

  final ProfileDao _dao;

  Future<Profile?> getProfile() async {
    final row = await _dao.getProfile();
    return row == null ? null : _toModel(row);
  }

  Stream<Profile?> watchProfile() =>
      _dao.watchProfile().map((row) => row == null ? null : _toModel(row));

  Future<void> save(Profile profile) async {
    await _dao.upsertProfile(
      ProfilesCompanion(
        age: Value(profile.age),
        gender: Value(profile.gender),
        heightCm: Value(profile.heightCm),
        weightKg: Value(profile.weightKg),
        goalWeightKg: Value(profile.goalWeightKg),
        activityLevel: Value(profile.activityLevel),
      ),
    );
  }

  Future<void> updateWeight(double weightKg) async {
    final existing = await _dao.getProfile();
    if (existing == null) return;
    await _dao.upsertProfile(
      ProfilesCompanion(
        age: Value(existing.age),
        gender: Value(existing.gender),
        heightCm: Value(existing.heightCm),
        weightKg: Value(weightKg),
        goalWeightKg: Value(existing.goalWeightKg),
        activityLevel: Value(existing.activityLevel),
      ),
    );
  }

  Profile _toModel(ProfileRow r) => Profile(
        age: r.age,
        gender: r.gender,
        heightCm: r.heightCm,
        weightKg: r.weightKg,
        goalWeightKg: r.goalWeightKg,
        activityLevel: r.activityLevel,
      );
}
